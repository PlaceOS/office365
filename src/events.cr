module Office365::Events
  def list_events(mailbox : String, calendar_group_id : String? = nil, calendar_id : String? = nil, query_params : Hash(String, String) = {} of String => String)
    endpoint = calendar_event_path(mailbox, calendar_group_id, calendar_id)

    response = graph_request(request_method: "GET", path: endpoint, query: {"$top" => "100"})

    if response.success?
      EventQuery.from_json response.body
    else
      raise "error fetching events list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_event(
    mailbox : String,
    starts_at : Time,
    ends_at : Time?,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
    **opts
  )
    event = Event.new(**opts.merge(starts_at: starts_at, ends_at: ends_at))
    endpoint = calendar_event_path(mailbox, calendar_group_id, calendar_id)

    response = graph_request(request_method: "POST", path: endpoint, data: event.to_json)

    if response.success?
      Event.from_json response.body
    else
      raise "error creating event #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def get_event(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}"
    response = graph_request(request_method: "GET", path: endpoint)

    if response.success?
      Event.from_json response.body
    else
      raise "error getting event #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def update_event(
    event : Event,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{event.id}"

    response = graph_request(request_method: "PATCH", path: endpoint, data: event.to_json)

    if response.success?
      Event.from_json response.body
    else
      raise "error updating event #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_event(
    id : String,
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = "#{calendar_event_path(mailbox, calendar_group_id, calendar_id)}/#{id}"

    response = graph_request(request_method: "DELETE", path: endpoint)

    if response.success?
      true
    else
      raise "error deleting event #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  private def calendar_event_path(
    mailbox : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
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

    endpoint
  end



end
