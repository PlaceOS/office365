module Office365
  enum FreeBusyStatus
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

  enum Sensitivity
    Normal
    Personal
    Private
    Confidential

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  class Event
    include JSON::Serializable

    property id : String?
    property showAs : FreeBusyStatus = FreeBusyStatus::Busy
    property responseRequested : Bool = true
    property subject : String = "Meeting"
    property attendees : Array(Attendee) = [] of Office365::Attendee
    property sensitivity : Sensitivity = Sensitivity::Normal
    property body : ItemBody = ItemBody.new
    property start : DateTimeTimeZone? = DateTimeTimeZone.new
    property end : DateTimeTimeZone? = DateTimeTimeZone.new(Time.local + 1.hour)
    property organizer : Recipient?
    property locations : Array(Location) = [] of Location
    property recurrence : PatternedRecurrence?
    property iCalUId : String?

    def initialize
    end

    def description
      @body.content
    end

    def description=(value : String)
      @body.content = value
    end

    def is_private?
      @sensitivity == "private"
    end

    def is_private(value : Bool)
      @sensitivity = value ? "private" : "normal"
    end

  end
end

