class Office365::DateTimeTimeZone
  include JSON::Serializable

  @[JSON::Field(key: "dateTime", converter: ::Time::Format.new("%FT%R"), emit_null: true)]
  property date_time : Time

  @[JSON::Field(key: "timeZone")]
  property time_zone : String

  def initialize(value : Time = Time.utc, tz : String = "UTC")
    @date_time = value.in(tz_location(tz))
    @time_zone = tz
  end

  def initialize(value : DateTimeTimeZone, tz : String)
    @date_time = value.date_time.in(tz_location(tz))
    @time_zone = tz
  end

  def self.convert(value : Time | DateTimeTimeZone) : DateTimeTimeZone
    case value
    when Time
      DateTimeTimeZone.new(value, extract_tz(value))
    else
      value
    end
  end

  def self.extract_tz(value : Time)
    tz = value.location.to_s
    case tz
    when "Local"
      "UTC"
    else
      tz
    end
  end

  private def tz_location(tz : String)
    loc = WindowsToTzdata.translate(tz)

    loc ? Time::Location.load(loc) : Time::Location.load(tz)
  end
end
