class Office365::Calendar
  include JSON::Serializable

  property id : String
  property start : Time
  property end : Time
  property subject : String
  property body : ItemBody
  property attendees : Array(Attendee)
  property iCalUId : String
  property showAs : String
  property isCancelled : Bool
  property isAllDay : Bool
  property sensitivity : String
  property location : Location
  property locations : Array(Location)
  property recurrence : PatternedRecurrence
  property seriesMasterId : String
  property type : String
  property createdDateTime : Time
  property changeKey : String
  property lastModifiedDateTime : Time
  property originalStartTimeZone : String
  property originalEndTimeZone : String
end
