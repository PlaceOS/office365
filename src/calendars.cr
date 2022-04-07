module Office365::Calendars
  def get_calendar_request(mailbox : String? = nil)
    query_params = {} of String => String

    case mailbox
    when nil
      endpoint = "/v1.0/me/calendar"
    when String
      endpoint = "#{USERS_BASE}/#{mailbox}/calendar"
    end

    graph_http_request(request_method: "GET", path: endpoint.not_nil!, query: query_params)
  end

  def get_calendar(*args, **opts)
    request = get_calendar_request(*args, **opts)
    response = graph_request(request)

    get_calendar(response)
  end

  def get_calendar(response : HTTP::Client::Response)
    Calendar.from_json response.body
  end

  def list_calendars_request(mailbox : String? = nil, calendar_group_id : String? = nil, match : String? = nil, search : String? = nil, limit : Int32? = nil)
    query_params = URI::Params.new

    if limit
      query_params["$top"] = limit
    end

    if match
      query_params["$filter"] = "name eq '#{match.gsub("'", "''")}'"
    elsif search
      query_params["$filter"] = "startswith(name,'#{search.gsub("'", "''")}')"
    end

    case {mailbox, calendar_group_id}
    when {nil, nil}
      endpoint = "/v1.0/me/calendars"
    when {String, nil}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendars"
    when {String, "default"}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroup/calendars"
    else
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars"
    end

    graph_http_request(request_method: "GET", path: endpoint, query: query_params)
  end

  def list_calendars(*args, **opts)
    request = list_calendars_request(*args, **opts)
    response = graph_request(request)

    list_calendars(response)
  end

  def list_calendars(response : HTTP::Client::Response)
    CalendarQuery.from_json response.body
  end

  def list_calendar_groups_request(mailbox : String?, limit : Int32 = 99)
    query_params = URI::Params{"$top" => ["#{limit}"]}

    case mailbox
    when nil
      endpoint = "/v1.0/me/calendarGroups"
    else
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups"
    end

    graph_http_request(request_method: "GET", path: endpoint, query: query_params)
  end

  def list_calendar_groups(*args, **opts)
    request = list_calendar_groups_request(*args, **opts)
    response = graph_request(request)

    list_calendar_groups(response)
  end

  def list_calendar_groups(response : HTTP::Client::Response)
    CalendarGroupQuery.from_json response.body
  end

  def create_calendar_request(mailbox : String, name : String, calendar_group_id : String? = nil)
    case calendar_group_id
    when nil
      endpoint = "#{USERS_BASE}/#{mailbox}/calendars"
    when "default"
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroup/calendars"
    else
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars"
    end

    graph_http_request(request_method: "POST", path: endpoint, data: {"name" => name}.to_json)
  end

  def create_calendar(*args, **opts)
    request = create_calendar_request(*args, **opts)
    response = graph_request(request)

    create_calendar(response)
  end

  def create_calendar(response : HTTP::Client::Response)
    Calendar.from_json response.body
  end

  def create_calendar_group_request(mailbox : String, name : String)
    endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups"
    graph_http_request(request_method: "POST", path: endpoint, data: {"name" => name}.to_json)
  end

  def create_calendar_group(*args, **opts)
    request = create_calendar_group_request(*args, **opts)
    response = graph_request(request)

    create_calendar_group(response)
  end

  def create_calendar_group(response : HTTP::Client::Response)
    CalendarGroup.from_json response.body
  end

  def delete_calendar_request(mailbox : String, id : String, calendar_group_id : String? = nil)
    case calendar_group_id
    when nil
      endpoint = "#{USERS_BASE}/#{mailbox}/calendars/#{id}"
    when "default"
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroup/calendars/#{id}"
    else
      endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars/#{id}"
    end

    graph_http_request(request_method: "DELETE", path: endpoint)
  end

  def delete_calendar(*args, **opts)
    request = delete_calendar_request(*args, **opts)
    response = graph_request(request)

    delete_calendar(response)
  end

  def delete_calendar(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  def delete_calendar_group_request(mailbox : String, id : String)
    endpoint = "#{USERS_BASE}/#{mailbox}/calendarGroups/#{id}"
    graph_http_request(request_method: "DELETE", path: endpoint)
  end

  def delete_calendar_group(*args, **opts)
    request = delete_calendar_group_request(*args, **opts)
    response = graph_request(request)

    delete_calendar_group(response)
  end

  def delete_calendar_group(response : HTTP::Client::Response)
    response.success? ? true : false
  end

  # default view_interval of 30mins, max number of mailboxes is 20 (batch for more)
  # https://docs.microsoft.com/en-us/graph/outlook-get-free-busy-schedule
  def get_availability_request(mailbox : String, mailboxes : Array(String), starts_at : Time, ends_at : Time, view_interval : Int32 = 30)
    endpoint = "#{USERS_BASE}/#{mailbox}/calendar/getSchedule"
    data = GetAvailabilityQuery.new(mailboxes, starts_at, ends_at, view_interval)

    graph_http_request(request_method: "POST", path: endpoint, data: data.to_json)
  end

  def get_availability(*args, **opts)
    request = get_availability_request(*args, **opts)
    response = graph_request(request)

    get_availability(response)
  end

  def get_availability(response : HTTP::Client::Response)
    AvailabilityQuery.from_json(response.body).value
  end
end
