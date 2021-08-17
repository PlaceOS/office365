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

  # Readonly meeting details
  class OnlineMeeting
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "joinUrl")]
    property join_url : String

    @[JSON::Field(key: "conferenceId")]
    property conference_id : String

    @[JSON::Field(key: "tollNumber")]
    property toll_number : String?

    @[JSON::Field(key: "quickDial")]
    property quick_dial : String?
  end

  class Event
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "start", converter: Office365::DateTimeTimeZone)]
    property starts_at : Time?

    @[JSON::Field(key: "end", converter: Office365::DateTimeTimeZone)]
    property ends_at : Time?

    @[JSON::Field(key: "iCalUId")]
    property icaluid : String?

    @[JSON::Field(key: "showAs")]
    property show_as : FreeBusyStatus

    @[JSON::Field(key: "responseRequested")]
    property? response_requested : Bool

    @[JSON::Field(key: "isAllDay")]
    property? all_day : Bool

    @[JSON::Field(key: "responseStatus")]
    property response_status : ResponseStatus?

    @[JSON::Field(key: "seriesMasterId")]
    property series_master_id : String?

    @[JSON::Field(key: "onlineMeetingProvider")]
    property online_meeting_provider : String?

    @[JSON::Field(key: "onlineMeetingUrl")]
    property online_meeting_url : String?

    @[JSON::Field(key: "isOnlineMeeting")]
    property is_online_meeting : Bool?

    @[JSON::Field(key: "onlineMeeting")]
    property online_meeting : OnlineMeeting?

    property id : String?
    property subject : String?
    property attendees : Array(Attendee) = [] of Office365::Attendee
    property sensitivity : Sensitivity
    property body : ItemBody?
    property organizer : Recipient?
    property locations : Array(Location)?
    property location : Location?

    @[JSON::Field(emit_null: true)]
    property recurrence : PatternedRecurrence?

    @[JSON::Field(key: "originalStartTimeZone")]
    property timezone : String = ""

    def initialize(
      @starts_at : Time = Time.local,
      @ends_at : Time | Nil = nil,
      @show_as = FreeBusyStatus::Busy,
      @response_requested = true,
      @subject = "Meeting",
      attendees : Array(Office365::Attendee | EmailAddress | String) = [] of Office365::Attendee | EmailAddress | String,
      @sensitivity = Sensitivity::Normal,
      description : String? = "",
      organizer : Recipient | EmailAddress | String | Nil = nil,
      location : String? = nil,
      recurrence : RecurrenceParam? = nil,
      @response_status : ResponseStatus? = nil,
      rooms : Array(String | EmailAddress) = [] of String | EmailAddress,
      @all_day = false,
      @id = nil,
      @series_master_id = nil,
      @online_meeting_provider = nil
    )
      @body = ItemBody.new(description)
      @is_online_meeting = @online_meeting_provider ? true : nil

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

      # As outlined in the example request
      # https://docs.microsoft.com/en-us/graph/api/user-post-events?view=graph-rest-1.0&tabs=http#request-1
      if location.is_a? String
        # Use the provided location
        @location = Location.new(display_name: location)
        @locations = [@location.not_nil!]
      else
        # Generate location based on invited resources
        @locations = locations = @attendees.compact_map { |a| Location.new(display_name: a.name) if a.type.resource? }
        @location = locations.first
      end

      if recurrence
        set_recurrence(recurrence)
      end

      case organizer
      when Recipient
        @organizer = organizer
      when String, EmailAddress
        @organizer = Recipient.new(organizer)
      when Nil
        # do nothing
      end
    end

    def description
      @body.try &.content
    end

    def description=(value : String?)
      @body = ItemBody.new(content: value)
    end

    def rooms
      @attendees.select(&.type.==(AttendeeType::Resource))
    end

    def is_private?
      @sensitivity == Sensitivity::Private
    end

    def is_private=(value : Bool)
      @sensitivity = value ? Sensitivity::Private : Sensitivity::Normal
    end

    def set_recurrence(recurrence)
      @recurrence = PatternedRecurrence.build(recurrence_start_date: @starts_at.not_nil!,
        recurrence: recurrence)
    end

    def online_meeting_url
      if meeting = @online_meeting
        meeting.join_url
      else
        @online_meeting_url
      end
    end

    def online_meeting_phone
      @online_meeting.try &.quick_dial || @online_meeting.try &.toll_number
    end

    def online_meeting_id
      @online_meeting.try &.conference_id
    end
  end
end
