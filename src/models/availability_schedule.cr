module Office365
  class AvailabilitySchedule
    include JSON::Serializable

    @[JSON::Field(key: "scheduleId")]
    property calendar : String

    @[JSON::Field(key: "scheduleItems")]
    property availability : Array(Availability)
  end
end
