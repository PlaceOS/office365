class Office365::DateTimeTimeZone
  include JSON::Serializable

  @[JSON::Field(converter: ::Time::Format.new("%FT%R"), emit_null: true)]
  property dateTime : Time
  property timeZone : String

  def initialize(value : Time = Time.utc, tz : String = "UTC")
    @dateTime = value.in(Time::Location.load(tz))
    @timeZone = tz
  end
end
