module Office365::Events
  def list_events_request(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    period_start : Time = Time.local.at_beginning_of_day,
    period_end : Time? = nil,
    ical_uid : String? = nil,
    top : Int32? = 10000,
    filter : String? = nil,
  )
    path, params = calendar_view_path(mailbox, calendar_group_id, calendar_id, period_start, period_end, ical_uid, top, filter)

    graph_http_request(request_method: "GET", path: path, query: params)
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
    **opts,
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
    calendar_id : String? = nil,
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
    calendar_id : String? = nil,
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
    calendar_id : String? = nil,
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

  def decline_event_request(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    notify : Bool = true,
    comment : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}/decline"

    graph_http_request(request_method: "POST", path: endpoint, data: {
      sendResponse: notify,
      comment:      comment,
    }.to_json)
  end

  def decline_event(*args, **opts)
    request = decline_event_request(*args, **opts)
    response = graph_request(request)

    decline_event(response)
  end

  def decline_event(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  def cancel_event_request(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    comment : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}/cancel"

    data = if comment
             {comment: comment}.to_json
           end

    graph_http_request(request_method: "POST", path: endpoint, data: data)
  end

  def cancel_event(*args, **opts)
    request = cancel_event_request(*args, **opts)
    response = graph_request(request)

    cancel_event(response)
  end

  def cancel_event(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  def accept_event_request(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    notify : Bool = true,
    comment : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}/accept"

    graph_http_request(request_method: "POST", path: endpoint, data: {
      sendResponse: notify,
      comment:      comment,
    }.to_json)
  end

  def accept_event(*args, **opts)
    request = accept_event_request(*args, **opts)
    response = graph_request(request)

    accept_event(response)
  end

  def accept_event(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  private def calendar_event_path(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    # we assume we are actually after a mailbox as calendar_ids are not emails
    if calendar_id.try &.includes?('@')
      mailbox = calendar_id
      calendar_id = nil
    end

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
    top : Int32? = 10000,
    filter : String? = nil,
  )
    end_period = period_end || period_start + 6.months

    # we assume we are actually after a mailbox as calendar_ids are not emails
    if calendar_id.try &.includes?('@')
      mailbox = calendar_id
      calendar_id = nil
    end

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

    query = String.build do |str|
      str << "startDateTime="
      str << period_start.to_utc.to_s("%FT%T-00:00")
      str << "&endDateTime="
      str << end_period.not_nil!.to_utc.to_s("%FT%T-00:00")
      if filter.presence
        str << "&"
        str << URI::Params.parse("$filter=#{filter}")
      elsif ical_uid.presence
        str << "&"
        str << URI::Params.parse("$filter=iCalUId eq '#{ical_uid}'")
      end
      if top
        str << "&$top="
        str << top
      end
    end

    {endpoint, URI::Params.parse(query)}
  end
end
