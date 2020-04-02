class Office365::CalendarGroupQuery
  include JSON::Serializable

  property value : Array(CalendarGroup)

  def initialize(@value)
  end
end
