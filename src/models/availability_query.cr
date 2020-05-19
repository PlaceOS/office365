module Office365
  class AvailabilityQuery
    include JSON::Serializable

    property value : Array(AvailabilitySchedule)
  end
end