module Office365::Events
  def list_events_request(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    period_start : Time = Time.local.at_beginning_of_day,
    period_end : Time? = nil,
    ical_uid : String? = nil
  )
    endpoint = calendar_view_path(mailbox, calendar_group_id, calendar_id, period_start, period_end, ical_uid)

    graph_http_request(request_method: "GET", path: endpoint)
  end

  def list_events(*args, **opts)
    request = list_events_request(*args, **opts)
    response = graph_request(request)

    list_events(response)
  end

  def list_events(response : HTTP::Client::Response)
    EventQuery.from_json response.body
  end

  def create_event_request(
    mailbox : String,
    starts_at : Time,
    ends_at : Time?,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    **opts
  )
    event = Event.new(**opts.merge(starts_at: starts_at, ends_at: ends_at))
    endpoint = calendar_event_path(mailbox, calendar_group_id, calendar_id)

    graph_http_request(request_method: "POST", path: endpoint, data: event.to_json)
  end

  def create_event(*args, **opts)
    request = create_event_request(*args, **opts)
    response = graph_request(request)

    create_event(response)
  end

  def create_event(response : HTTP::Client::Response)
    Event.from_json response.body
  end

  def get_event_request(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}"
    graph_http_request(request_method: "GET", path: endpoint)
  end

  def get_event(*args, **opts)
    request = get_event_request(*args, **opts)
    response = graph_request(request)

    get_event(response)
  end

  def get_event(response : HTTP::Client::Response)
    Event.from_json response.body
  end

  def update_event_request(
    event : Event,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{event.id}"

    graph_http_request(request_method: "PATCH", path: endpoint, data: event.to_json)
  end

  def update_event(*args, **opts)
    request = update_event_request(*args, **opts)
    response = graph_request(request)

    update_event(response)
  end

  def update_event(response : HTTP::Client::Response)
    Event.from_json response.body
  end

  def delete_event_request(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}"

    graph_http_request(request_method: "DELETE", path: endpoint)
  end

  def delete_event(*args, **opts)
    request = delete_event_request(*args, **opts)
    response = graph_request(request)

    delete_event(response)
  end

  def delete_event(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  private def calendar_event_path(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    case {calendar_group_id, calendar_id}
    when {Nil, Nil}
      "#{USERS_BASE}/#{mailbox}/calendar/events"
    when {Nil, String}
      "#{USERS_BASE}/#{mailbox}/calendars/#{calendar_id}/events"
    when {"default", String}
      "#{USERS_BASE}/#{mailbox}/calendargroup/calendars/#{calendar_id}/events"
    when {String, String}
      "#{USERS_BASE}/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/events"
    else
      raise "unknown endpoint"
    end
  end

  private def calendar_view_path(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    period_start : Time = Time.local.at_beginning_of_day,
    period_end : Time? = nil,
    ical_uid : String? = nil,
    top : UInt16? = 10000
  )
    end_period = period_end || period_start + 6.months

    endpoint = case {calendar_group_id, calendar_id}
               when {Nil, Nil}
                 "#{USERS_BASE}/#{mailbox}/calendar/calendarView"
               when {Nil, String}
                 "#{USERS_BASE}/#{mailbox}/calendars/#{calendar_id}/calendarView"
               when {"default", String}
                 "#{USERS_BASE}/#{mailbox}/calendargroup/calendars/#{calendar_id}/calendarView"
               when {String, String}
                 "#{USERS_BASE}/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/calendarView"
               else
                 raise "unknown endpoint"
               end

    ical_filter = HTTP::Params.parse(ical_uid.presence ? "$filter=iCalUId eq '#{ical_uid}'" : "").to_s
    ical_filter = "&#{ical_filter}" unless ical_filter.empty?
    "#{endpoint}?startDateTime=#{period_start.to_s("%FT%T-00:00")}&endDateTime=#{end_period.not_nil!.to_s("%FT%T-00:00")}#{ical_filter}&$top=#{top}"
  end
end
