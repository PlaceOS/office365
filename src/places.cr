module Office365::Places
  def list_places_request(type : PlaceType = PlaceType::Room, filter : String? = nil, match : String? = nil, top : Int32? = nil, skip : Int32? = nil, count : Bool? = nil)
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

    graph_http_request(request_method: "GET", path: "#{PLACES_BASE}/microsoft.graph.#{type}", query: query_params)
  end

  def list_places(*args, **opts)
    request = list_places_request(*args, **opts)
    response = graph_request(request)

    list_places(response)
  end

  def list_places(response : HTTP::Client::Response)
    PlaceList.from_json(response.body)
  end

  def list_rooms(*args, **opts)
    list_places(*args, **opts)
  end

  def list_room_list(*args, **opts)
    list_places(*args, **opts, type: PlaceType::RoomList)
  end

  def list_rooms_in_room_list(email : String)
    request = graph_http_request(request_method: "GET", path: "#{PLACES_BASE}/#{URI.encode_www_form(email)}/microsoft.graph.roomlist/rooms")
    response = graph_request(request)
    RoomLists.from_json(response.body)
  end

  def get_place_request(id : String)
    graph_http_request(request_method: "GET", path: "#{PLACES_BASE}/#{id}")
  end

  def get_room(id : String)
    request = get_place_request(id)
    response = graph_request(request)
    Room.from_json(response.body)
  end

  def get_room_list(email : String)
    request = get_place_request(URI.encode_www_form(email))
    response = graph_request(request)
    RoomList.from_json(response.body)
  end
end
