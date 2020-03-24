class Office365::RecurrenceRange
  include JSON::Serializable

  property endDate : String
  property numberOfOccurrences : Int32
  property recurrenceTimeZone : String
  property startDate : String
  property type : String
end
