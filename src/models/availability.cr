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

    @[JSON::Field(key: "start", converter: Office365::DateTimeTimeZone)]
    property starts_at : Time?

    @[JSON::Field(key: "end", converter: Office365::DateTimeTimeZone)]
    property ends_at : Time?

    property status : AvailabilityStatus

    def initialize(@starts_at, @ends_at, @status)
    end
  end
end
