require "kemal"

module SimpleStocksApp
  VERSION = "0.1.0"

  get "/moex_last_hour/" do |env|
    {
      "last": 5000
    }.to_json
  end

  port = (ENV["PORT"]? || 8080).to_i
  Kemal.run port
end
