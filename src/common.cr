module SimpleStocksApp
  # Тип интервала
  enum IntervalType
    Now
    Minute
    Hour
    Day
    Month

    def self.from_s(v : String) : IntervalType
      case v
      when "now"
        return IntervalType::Now
      when "minute"
        return IntervalType::Minute
      when "hour"
        return IntervalType::Hour
      when "day"
        return IntervalType::Day
      when "month"
        return IntervalType::Month
      end

      raise Exception.new("Unknown IntervalType")
    end
  end

  # Данные с датой
  class ValueWithDate
    # Время
    getter date : Time

    # Значение
    property value : Float64

    def initialize(@date, @value = 0_f64)
    end
  end

  # Данные по свече
  class CandleData
    getter interval : IntervalType
    # Дата свечи
    getter date : Time
    # Цена открытия
    getter open : Float64
    # Цена закрытия
    getter close : Float64
    # Максимальное значение
    getter high : Float64
    # Минимальное значение
    getter low : Float64
    # Объём торгов
    getter volume : Float64

    def initialize(@interval, @date, @close, @open, @high, @low, @volume)
    end

    def to_dict
      {
        "interval" => interval.to_s,
        "date"     => date,
        "open"     => open,
        "close"    => close,
        "high"     => close,
        "low"      => low,
        "low"      => low,
      }
    end
  end
end

# Расширение для Time
struct Time
  # Добавляет интервал
  def add_interval(interval : Fipo::IntervalType, count : Int32 = 1) : Time
    case interval
    when Fipo::IntervalType::Minute
      return self + count.minutes
    when Fipo::IntervalType::Hour
      return self + count.hours
    when Fipo::IntervalType::Day
      return self + count.days
    end

    return self
  end

  # Выпавнивает на границу интервала
  def align(interval : SimpleStocksApp::IntervalType, at_end = false)
    case interval
    when SimpleStocksApp::IntervalType::Now
      return self
    when SimpleStocksApp::IntervalType::Minute
      return at_end ? self.at_end_of_minute : self.at_beginning_of_minute
    when SimpleStocksApp::IntervalType::Hour
      return at_end ? self.at_end_of_hour : self.at_beginning_of_hour
    when SimpleStocksApp::IntervalType::Day
      return at_end ? self.at_end_of_day : self.at_beginning_of_day
    end

    return self
  end
end
