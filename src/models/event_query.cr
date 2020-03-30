class Office365::EventQuery
  include JSON::Serializable

  property value : Array(Event)
end
