module Office365
  class AvailabilitySchedule
    include JSON::Serializable

    @[JSON::Field(key: "scheduleId")]
    property calendar : String

    @[JSON::Field(key: "scheduleItems")]
    property availability : Array(Availability) = [] of Office365::Availability
  end
end
