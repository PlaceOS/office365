class Office365::CalendarQuery
  include JSON::Serializable

  property value : Array(Calendar)

  def initialize(@value)
  end
end
