require "kemal"
require "./common"
require "./moex_api"

module SimpleStocksApp
  VERSION = "0.1.0"

  # Возвращает значение доллара
  get "/dollar" do |env|
    env.response.content_type = "application/json"
    url = "https://www.cbr-xml-daily.ru/latest.js"
    p url
    response = Crest.get(
      url
    )

    json = JSON.parse(response.body)
    usd = 1.0 / json["rates"]["USD"].to_s.to_f

    next {
      "usd": usd,
    }.to_json
  end

  # Возвращает значение закрытия последней свечи
  # ticker - название бумаги
  # interval - тип интервала: час, день, месяц
  # Пример: /moex_last_value?ticker=GAZP&interval=hour
  get "/moex_last_value" do |env|
    env.response.content_type = "application/json"
    ticker = env.params.query["ticker"]?
    intervalStr = env.params.query["interval"]?
    if (ticker == nil) || (intervalStr == nil)
      halt env, status_code: 400, response: "Bad request"
    end

    interval = IntervalType.from_s(intervalStr.not_nil!)

    end_date = Time.local
    start_date = end_date - 7.days

    candles = MoexApi.instance.get_chart_for_interval(ticker.not_nil!, MoexMarketType::Shares, interval, start_date, end_date)
    candles.sort { |a, b| a.date <=> b.date }

    last_candle = candles.last

    {
      "last": last_candle.close,
      "date": last_candle.date
    }.to_json
  end

  port = (ENV["PORT"]? || 8080).to_i
  Kemal.run port
end
