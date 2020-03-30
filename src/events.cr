module Office365::Events
  def list_events(mailbox : String, calendar_group_id : String? = nil, calendar_id : String? = nil, query_params : Hash(String, String) = {} of String => String)
    endpoint = ""
    case {calendar_group_id, calendar_id}
    when {Nil, Nil}
      endpoint = "/v1.0/users/#{mailbox}/calendar/events"
    when {Nil, String}
      endpoint = "/v1.0/users/#{mailbox}/calendars/#{calendar_id}/events"
    when {"default", String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroup/calendars/#{calendar_id}/events"
    when {String, String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/events"
    end

    response = graph_request(request_method: "GET", path: endpoint, query: query_params)

    if response.success?
      EventQuery.from_json response.body
    else
      raise "error fetching events list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_event(mailbox : String, starts_at : Time, ends_at : Time, calendar_group_id : String? = nil, calendar_id : String? = nil, **opts)

    default_options = {
      rooms: [] of String,
      subject: "Meeting",
      description: "",
      organizer: mailbox,
      attendees: [] of String,
      recurrence: nil,
      is_private: false,
      timezone: ENV["TZ"] || "UTC",
      location: nil,
      showAs: "busy",
      responseRequested: true,
    }
#    event = Office365::Event.new(
#
#    opts = opts.reverse_merge(default_options)
#
#    event_json = create_event_json(**opts)

  end


end
