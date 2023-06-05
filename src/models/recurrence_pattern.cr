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

    @[JSON::Field(key: "dayOfMonth")]
    property day_of_month : Int32?

    @[JSON::Field(key: "daysOfWeek")]
    property days_of_week : Array(DayOfWeek)?

    @[JSON::Field(key: "firstDayOfWeek")]
    property first_day_of_week : DayOfWeek = DayOfWeek::Sunday

    property index : WeekIndex?
    property interval : Int32?
    property month : Int32?
    property type : RecurrencePatternType?

    def initialize(@type, @interval)
    end

    def initialize(@type, @interval, @days_of_week)
    end

    def initialize(@type, @interval, @days_of_week, @first_day_of_week)
    end
  end
end
