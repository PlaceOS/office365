module Office365
  module TimezoneConverter
    def self.from_json(value : JSON::PullParser) : String
      tz = value.read_string
      translated = WindowsToTzdata.translate(tz)
      translated ? translated : tz
    end

    def self.to_json(value : String, json : JSON::Builder)
      json.string(value.to_s)
    end
  end

  class RecurrenceRange
    include JSON::Serializable

    @[JSON::Field(key: "startDate")]
    property start_date : String

    @[JSON::Field(key: "endDate")]
    property end_date : String

    @[JSON::Field(key: "recurrenceTimeZone", converter: Office365::TimezoneConverter)]
    property recurrence_time_zone : String?

    property type : String

    def initialize(@type, @start_date, @end_date)
    end
  end
end
