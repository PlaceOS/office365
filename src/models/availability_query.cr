module Office365
  class AvailabilityQuery
    include JSON::Serializable

    property value : Array(AvailabilitySchedule)
  end

  class GetAvailabilityQuery
    include JSON::Serializable

    property schedules : Array(String)

    @[JSON::Field(key: "startTime", converter: Office365::DateTimeTimeZone)]
    property starts_at : Time

    @[JSON::Field(key: "endTime", converter: Office365::DateTimeTimeZone)]
    property ends_at : Time

    @[JSON::Field(key: "availabilityViewInterval")]
    property view_interval : Int32

    def initialize(@schedules, @starts_at, @ends_at, @view_interval)
    end
  end
end
