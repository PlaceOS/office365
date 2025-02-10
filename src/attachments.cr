module Office365::Attachments
  def list_attachments_request(mailbox : String,
                               event_id : String,
                               calendar_group_id : String? = nil,
                               calendar_id : String? = nil)
    endpoint = event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)

    graph_http_request(request_method: "GET", path: endpoint, query: URI::Params{"$top" => ["100"]})
  end

  def list_attachments(*args, **opts)
    request = list_attachments_request(*args, **opts)
    response = graph_request(request)

    list_attachments(response)
  end

  def list_attachments(response : HTTP::Client::Response)
    if response.success?
      AttachmentQuery.from_json response.body
    else
      raise "error fetching attachments list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_attachment_request(
    mailbox : String,
    event_id : String,
    name : String,
    content_bytes : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    attachment = Attachment.new(name, content_bytes)
    endpoint = event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)

    graph_http_request(request_method: "POST", path: endpoint, data: attachment.to_json)
  end

  def create_attachment(*args, **opts)
    request = create_attachment_request(*args, **opts)
    response = graph_request(request)

    create_attachment(response)
  end

  def create_attachment(response : HTTP::Client::Response)
    if response.success?
      Attachment.from_json response.body
    else
      raise "error creating attachment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def get_attachment_request(
    id : String,
    mailbox : String,
    event_id : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = "#{event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)}/#{id}"
    graph_http_request(request_method: "GET", path: endpoint)
  end

  def get_attachment(*args, **opts)
    request = get_attachment_request(*args, **opts)
    response = graph_request(request)

    get_attachment(response)
  end

  def get_attachment(response : HTTP::Client::Response)
    if response.success?
      Attachment.from_json response.body
    else
      raise "error getting attachment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_attachment_request(
    id : String,
    mailbox : String,
    event_id : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = "#{event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)}/#{id}"

    graph_http_request(request_method: "DELETE", path: endpoint)
  end

  def delete_attachment(*args, **opts)
    request = delete_attachment_request(*args, **opts)
    response = graph_request(request)

    delete_attachment(response)
  end

  def delete_attachment(response : HTTP::Client::Response)
    if response.success?
      true
    else
      raise "error deleting attachment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  private def event_attachment_path(
    mailbox : String,
    event_id : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil,
  )
    endpoint = ""

    case {calendar_group_id, calendar_id}
    when {Nil, Nil}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendar/events/#{event_id}/attachments"
    when {Nil, String}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendars/#{calendar_id}/events/#{event_id}/attachments"
    when {"default", String}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendargroup/calendars/#{calendar_id}/events/#{event_id}/attachments"
    when {String, String}
      endpoint = "#{USERS_BASE}/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/events/#{event_id}/attachments"
    end

    endpoint
  end
end
