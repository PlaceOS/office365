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

    @[JSON::Field(key: "start")]
    property starts_at : DateTimeTimeZone?

    @[JSON::Field(key: "end")]
    property ends_at : DateTimeTimeZone?

    @[JSON::Field(key: "iCalUId")]
    property icaluid : String?

    @[JSON::Field(key: "showAs")]
    property show_as : FreeBusyStatus

    @[JSON::Field(key: "responseRequested")]
    property? response_requested : Bool

    @[JSON::Field(key: "isAllDay")]
    property? all_day : Bool

    property id : String?
    property subject : String?
    property attendees : Array(Attendee) = [] of Office365::Attendee
    property sensitivity : Sensitivity
    property body : ItemBody?
    property organizer : Recipient?
    property locations : Array(Location)?
    property recurrence : PatternedRecurrence?

    def initialize(
      starts_at : DateTimeTimeZone | Time = Time.local,
      ends_at : DateTimeTimeZone | Time | Nil = nil,
      @show_as = FreeBusyStatus::Busy,
      @response_requested = true,
      @subject = "Meeting",
      attendees : Array(Office365::Attendee | EmailAddress | String) = [] of Office365::Attendee | EmailAddress | String,
      @sensitivity = Sensitivity::Normal,
      description : String? = "",
      organizer : Recipient | EmailAddress | String | Nil = nil,
      location : String? = nil,
      @recurrence = nil,
      rooms : Array(String | EmailAddress) = [] of String | EmailAddress,
      @all_day = false
    )
      @starts_at = DateTimeTimeZone.convert(starts_at)
      @ends_at = !ends_at.nil? ? DateTimeTimeZone.convert(ends_at) : nil
      @body = ItemBody.new(description)

      attendees.each do |attendee|
        case attendee
        when String, EmailAddress
          @attendees << Attendee.new(attendee)
        when Attendee
          @attendees << attendee
        end
      end

      rooms.each do |room|
        @attendees << Attendee.new(room, AttendeeType::Resource)
      end

      if typeof(location) == String
        @locations = [Location.new(display_name: location)]
      else
        @locations = @attendees.map { |a| Location.new(display_name: a.name) if a.type == AttendeeType::Resource }.compact
      end

      case organizer
      when Recipient
        @organizer = organizer
      when String, EmailAddress
        @organizer = Recipient.new(organizer)
      end
    end

    def description
      @body.try &.content
    end

    def description=(value : String?)
      @body = ItemBody.new(content: value)
    end

    def rooms
      @attendees.select { |a| a.type == AttendeeType::Resource }
    end

    def is_private?
      @sensitivity == Sensitivity::Private
    end

    def is_private=(value : Bool)
      @sensitivity = value ? Sensitivity::Private : Sensitivity::Normal
    end
  end
end
