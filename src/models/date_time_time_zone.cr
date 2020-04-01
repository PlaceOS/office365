class Office365::DateTimeTimeZone
  include JSON::Serializable

  @[JSON::Field(key: "dateTime", converter: ::Time::Format.new("%FT%R"), emit_null: true)]
  property date_time : Time

  @[JSON::Field(key: "timeZone")]
  property time_zone : String

  def initialize(value : Time = Time.utc, tz : String = "UTC")
    @date_time = value.in(Time::Location.load(tz))
    @time_zone = tz
  end

  def self.convert(value : Time | DateTimeTimeZone) : DateTimeTimeZone
    case value
    when Time
      DateTimeTimeZone.new(value)
    else
      value
    end
  end
end
