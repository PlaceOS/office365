module Office365::Attachments
  def list_attachments(mailbox : String,
                       event_id : String,
                       calendar_group_id : String? = nil,
                       calendar_id : String? = nil)
    endpoint = event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)

    response = graph_request(request_method: "GET", path: endpoint, query: {"$top" => "100"})

    if response.success?
      AttachmentQuery.from_json response.body
    else
      raise "error fetching attachments list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_attachment(
    mailbox : String,
    event_id : String,
    name : String,
    content_bytes : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    attachment = Attachment.new(name, content_bytes)
    endpoint = event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)

    response = graph_request(request_method: "POST", path: endpoint, data: attachment.to_json)

    if response.success?
      Attachment.from_json response.body
    else
      raise "error creating attachment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def get_attachment(
    id : String,
    mailbox : String,
    event_id : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    endpoint = "#{event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)}/#{id}"
    response = graph_request(request_method: "GET", path: endpoint)

    if response.success?
      Attachment.from_json response.body
    else
      raise "error getting attachment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_attachment(
    id : String,
    mailbox : String,
    event_id : String,
    calendar_group_id : String? = nil,
    calendar_id : String? = nil
  )
    endpoint = "#{event_attachment_path(mailbox, event_id, calendar_group_id, calendar_id)}/#{id}"

    response = graph_request(request_method: "DELETE", path: endpoint)

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
    calendar_id : String? = nil
  )
    endpoint = ""

    case {calendar_group_id, calendar_id}
    when {Nil, Nil}
      endpoint = "/v1.0/users/#{mailbox}/calendar/events/#{event_id}/attachments"
    when {Nil, String}
      endpoint = "/v1.0/users/#{mailbox}/calendars/#{calendar_id}/events/#{event_id}/attachments"
    when {"default", String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroup/calendars/#{calendar_id}/events/#{event_id}/attachments"
    when {String, String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/events/#{event_id}/attachments"
    end

    endpoint
  end
end
