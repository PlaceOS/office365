module Office365::ChannelMessages
  def list_channel_messages_request(team_id : String, channel_id : String, filter : String? = nil, match : String? = nil, top : Int32? = nil, skip : Int32? = nil, count : Bool? = nil)
    query_params = URI::Params.new

    if top
      query_params["$top"] = top.to_s
    end

    if count
      query_params["$count"] = count.to_s
    end

    if filter
      query_params["$filter"] = filter
    end

    if match
      query_params["$select"] = match
    end

    if skip
      query_params["$skip"] = skip.to_s
    end

    graph_http_request(request_method: "GET", path: "/v1.0/teams/#{team_id}/channels/#{channel_id}/messages", query: query_params)
  end

  def list_channel_messages(*args, **opts)
    request = list_channel_messages_request(*args, **opts)
    response = graph_request(request)

    list_channel_messages(response)
  end

  def list_channel_messages(response : HTTP::Client::Response)
    if response.success?
      ChatMessageList.from_json(response.body)
    else
      raise "error listing channel messages #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def get_channel_message(team_id : String, channel_id : String, message_id : String)
    request = graph_http_request(request_method: "GET", path: "/v1.0/teams/#{team_id}/channels/#{channel_id}/messages/#{message_id}")
    response = graph_request(request)
    if response.success?
      ChatMessage.from_json(response.body)
    else
      raise "error getting channel message #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def send_channel_message(team_id : String, channel_id : String, message : String | IO)
    body = message.is_a?(IO) ? message.gets_to_end : message
    chat = ChatMessage.new(body: body)
    request = graph_http_request(request_method: "POST", path: "/v1.0/teams/#{team_id}/channels/#{channel_id}/messages", data: chat.to_json)
    response = graph_request(request)

    if response.success?
      ChatMessage.from_json(response.body)
    else
      raise "error sending channel message #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def send_channel_message(team_id : String, channel_id : String, message : String | IO, content_type : String)
    body = message.is_a?(IO) ? message.gets_to_end : message
    chat = ChatMessage.new(content: body, content_type: content_type)
    request = graph_http_request(request_method: "POST", path: "/v1.0/teams/#{team_id}/channels/#{channel_id}/messages", data: chat.to_json)
    response = graph_request(request)
    if response.success?
      ChatMessage.from_json(response.body)
    else
      raise "error sending channel message #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end
end
