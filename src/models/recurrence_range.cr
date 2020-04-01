class Office365::RecurrenceRange
  include JSON::Serializable

  @[JSON::Field(key: "startDate")]
  property start_date : String

  @[JSON::Field(key: "endDate")]
  property end_date : String

  @[JSON::Field(key: "numberOfOccurrences")]
  property number_of_occurrences : Int32

  @[JSON::Field(key: "recurrenceTimeZone")]
  property recurrence_time_zone : String

  property type : String
end
