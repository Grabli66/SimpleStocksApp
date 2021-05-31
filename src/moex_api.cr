require "crest"
require "./common"

module SimpleStocksApp
  enum IntervalType
    # Переводит в интервал yahoo для запроса
    def to_moex_interval
      case self
      when IntervalType::Minute
        return "1"
      when IntervalType::Hour
        return "60"
      when IntervalType::Day
        return "24"
      when IntervalType::Month
        return "31"
      end
      raise Exception.new("Unknown interval")
    end
  end

  # Тип рынков на бирже moex
  enum MoexMarketType
    Bonds
    Shares

    def to_moex
      case self
      when Bonds
        return "bonds"
      when Shares
        return "shares"
      end

      raise Exception.new("Unknown market")
    end
  end

  # API для moex
  class MoexApi
    @@instance = MoexApi.new

    def self.instance
      @@instance
    end

    # Возвращает свечной график за интервал
    def get_chart_for_interval(ticker : String, market : MoexMarketType, interval : IntervalType, start_date : Time, end_date : Time) : Array(CandleData)      
      start_date = start_date.align(interval)
      start_date_str = start_date.to_s("%Y-%m-%d")
      end_date = end_date.align(interval)
      end_date_str = end_date.to_s("%Y-%m-%d")
      interval_str = interval.to_moex_interval
      market_str = market.to_moex
      url = "https://iss.moex.com/iss/engines/stock/markets/#{market_str}/securities/#{ticker}/candles.json?interval=#{interval_str}&from=#{start_date_str}&till=#{end_date_str}"
      p url
      response = Crest.get(
        url
      )

      json = JSON.parse(response.body)
      data = json["candles"]["data"].as_a
      res = data.compact_map do |x|        
        open = x[0].to_s.to_f
        close = x[1].to_s.to_f
        high = x[2].to_s.to_f
        low = x[3].to_s.to_f
        volume = x[5].to_s.to_f

        if market == MoexMarketType::Bonds
          value = x[4].to_s.to_f
          val = value / volume
          open = val
          close = val
          high = val
          low = val
        end
        
        date = Time.parse(x[6].to_s, "%Y-%m-%d %H:%M:%S", Time::Location::UTC)
        CandleData.new(
          interval: interval,
          date: date,
          open: open,
          close: close,
          high: high,
          low: low,
          volume: volume
        )
      end
      return res
    end
  end
end
