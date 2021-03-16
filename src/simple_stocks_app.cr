require "kemal"
require "./common"
require "./moex_api"

module SimpleStocksApp
  VERSION = "0.1.0"
  
  # Возвращает значение доллара
  get "/dollar" do |env|
    url = "https://www.cbr-xml-daily.ru/latest.js"
      p url
      response = Crest.get(
        url
      )

      json = JSON.parse(response.body)
      usd = 1.0 / json["rates"]["USD"].to_s.to_f

      next {
        "USD": usd
      }.to_json
  end

  # Возвращает значение закрытия последней часовой свечи
  get "/moex_last_hour" do |env|
    env.response.content_type = "application/json"
    ticker = env.params.query["ticker"]    

    end_date = Time.local
    start_date = end_date - 7.days
        
    candles = MoexApi.instance.get_chart_for_interval(ticker, MoexMarketType::Shares, IntervalType::Hour, start_date, end_date)
    candles.sort { |a, b| a.date <=> b.date }    
    
    last_candle = candles.last

    {
      "last": last_candle.close
    }.to_json
  end

  port = (ENV["PORT"]? || 8080).to_i
  Kemal.run port
end