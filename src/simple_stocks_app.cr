require "kemal"
require "./moex_api"

module SimpleStocksApp
  VERSION = "0.1.0"
  
  get "/moex_last_hour/" do |env|
    env.response.content_type = "application/json"
    ticker = env.params.query["ticker"]

    end_date = Time.local
    start_date = end_date - 7.days

    candles = MoexApi.instance.get_chart_for_interval(ticker, MoexMarketType::Shares, IntervalType::Hour, start_date, end_date)
    last_candle = candles.last

    {
      "last": last_candle.close
    }.to_json
  end

  port = (ENV["PORT"]? || 8080).to_i
  Kemal.run port
end
