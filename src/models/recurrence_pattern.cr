module Office365
  enum DayOfWeek
    Sunday
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  enum RecurrencePatternType
    Daily
    Weekly
    AbsoluteMonthly
    RelativeMonthly
    AbsoluteYearly
    RelativeYearly

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  enum WeekIndex
    First
    Second
    Third
    Fourth
    Last

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  class RecurrencePattern
    include JSON::Serializable

    property dayOfMonth : Int32?
    property daysOfWeek : Array(DayOfWeek)?
    property firstDayOfWeek : DayOfWeek?
    property index : WeekIndex?
    property interval : Int32?
    property month : Int32?
    property type : RecurrencePatternType?

    def initialize
    end
  end
end
