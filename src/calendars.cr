module Office365::Calendars
  def list_calendars(mailbox : String, calendar_group_id : String? = nil, match : String? = nil, search : String? = nil, limit : Int32? = nil)
    query_params = {} of String => String

    if limit
      query_params["$top"] = "#{limit}"
    end

    if match
      query_params["$filter"] = "name eq '#{match.gsub("'", "''")}'"
    elsif search
      query_params["$filter"] = "startswith(name,'#{search.gsub("'", "''")}')"
    end

    case calendar_group_id
    when nil
      endpoint = "/v1.0/users/#{mailbox}/calendars"
    when "default"
      endpoint = "/v1.0/users/#{mailbox}/calendarGroup/calendars"
    else
      endpoint = "/v1.0/users/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars"
    end

    response = graph_request(request_method: "GET", path: endpoint, query: query_params)
    if response.success?
      CalendarQuery.from_json response.body
    else
      raise "error fetching calendars list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def list_calendar_groups(mailbox : String, limit : Int32 = 99)
    query_params = {"$top" => "#{limit}"}
    endpoint = "/v1.0/users/#{mailbox}/calendarGroups"
    response = graph_request(request_method: "GET", path: endpoint, query: query_params)

    if response.success?
      CalendarGroupQuery.from_json response.body
    else
      raise "error fetching calendar groups list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_calendar(mailbox : String, name : String, calendar_group_id : String? = nil)
    case calendar_group_id
    when nil
      endpoint = "/v1.0/users/#{mailbox}/calendars"
    when "default"
      endpoint = "/v1.0/users/#{mailbox}/calendarGroup/calendars"
    else
      endpoint = "/v1.0/users/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars"
    end

    response = graph_request(request_method: "POST", path: endpoint, data: {"name" => name}.to_json)

    if response.success?
      Calendar.from_json response.body
    else
      raise "error creating calendar #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_calendar_group(mailbox : String, name : String)
    endpoint = "/v1.0/users/#{mailbox}/calendarGroups"
    response = graph_request(request_method: "POST", path: endpoint, data: {"name" => name}.to_json)

    if response.success?
      CalendarGroup.from_json response.body
    else
      raise "error creating calendar group #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_calendar(mailbox : String, id : String, calendar_group_id : String? = nil)
    case calendar_group_id
    when nil
      endpoint = "/v1.0/users/#{mailbox}/calendars/#{id}"
    when "default"
      endpoint = "/v1.0/users/#{mailbox}/calendarGroup/calendars/#{id}"
    else
      endpoint = "/v1.0/users/#{mailbox}/calendarGroups/#{calendar_group_id}/calendars/#{id}"
    end

    response = graph_request(request_method: "DELETE", path: endpoint)

    if response.success?
      true
    else
      raise "error deleting calendar #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_calendar_group(mailbox : String, id : String)
    endpoint = "/v1.0/users/#{mailbox}/calendarGroups/#{id}"
    response = graph_request(request_method: "DELETE", path: endpoint)

    if response.success?
      true
    else
      raise "error deleting calendar group #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end
end
