class Office365::RecurrencePattern
  include JSON::Serializable

  property dayOfMonth : Int32
  property daysOfWeek : Array(String)
  property firstDayOfWeek : String
  property index : String
  property interval : Int32
  property month : Int32
  property type : String
end
