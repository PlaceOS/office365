module Office365
  enum AvailabilityStatus
    Free
    Tentative
    Busy
    Oof
    WorkingElsewhere
    Uknown

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  class Availability
    include JSON::Serializable

    @[JSON::Field(key: "start")]
    property starts_at : DateTimeTimeZone?

    @[JSON::Field(key: "end")]
    property ends_at : DateTimeTimeZone?

    property status : AvailabilityStatus

    def initialize(@starts_at, @ends_at, @status)
    end
  end
end