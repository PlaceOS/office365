module Office365::Groups
  # https://docs.microsoft.com/en-us/graph/api/group-list?view=graph-rest-1.0&tabs=http
  def list_groups_request(q : String? = nil)
    if q.presence
      filter_param = "startswith(displayName, '#{q}')"
    end

    query_params = URI::Params.new({
      "$filter" => filter_param,
      # doesn't support 999
      "$top" => "950",
    }.compact.transform_values { |val| [val] })

    # This is required to do searching
    headers = HTTP::Headers{"ConsistencyLevel" => "eventual"}
    headers.merge! default_headers

    graph_http_request(
      request_method: "GET",
      path: "/v1.0/groups",
      query: query_params,
      headers: headers
    )
  end

  def list_groups(*args, **opts)
    request = list_groups_request(*args, **opts)
    list_groups graph_request(request)
  end

  def list_groups(response : HTTP::Client::Response)
    GroupQuery.from_json response.body
  end

  def get_group_request(id : String)
    graph_http_request(request_method: "GET", path: "/v1.0/groups/#{id}")
  end

  def get_group(*args, **opts)
    request = get_group_request(*args, **opts)
    get_group graph_request(request)
  end

  def get_group(response : HTTP::Client::Response)
    Group.from_json response.body
  end

  # https://docs.microsoft.com/en-us/graph/api/group-list-members?view=graph-rest-1.0&tabs=http
  def list_group_members_request(group_id : String, q : String? = nil)
    if q.presence
      filter_param = %("displayName:#{q}")
    end

    query_params = URI::Params.new({
      "$orderby" => "displayName",
      "$search"  => filter_param,
      "$top"     => "999",
    }.compact.transform_values { |val| [val] })

    # This is required to do searching
    headers = HTTP::Headers{"ConsistencyLevel" => "eventual"}
    headers.merge! default_headers

    graph_http_request(
      request_method: "GET",
      path: "/v1.0/groups/#{group_id}/members/microsoft.graph.user",
      query: query_params,
      headers: headers
    )
  end

  def list_group_members(*args, **opts)
    request = list_group_members_request(*args, **opts)
    list_group_members graph_request(request)
  end

  def list_group_members(response : HTTP::Client::Response)
    UserQuery.from_json response.body
  end

  # MemberOf Request, what groups a user is in (defaults to including nested groups)
  def groups_member_of_request(user_id : String, q : String? = nil, transitive : Bool? = true)
    if q.presence
      filter_param = %("displayName:#{q}")
    end

    query_params = URI::Params.new({
      "$orderby" => "displayName",
      "$search"  => filter_param,
      "$top"     => "999",
    }.compact.transform_values { |val| [val] })

    # This is required to do searching
    headers = HTTP::Headers{"ConsistencyLevel" => "eventual"}
    headers.merge! default_headers

    member_of = transitive ? "transitiveMemberOf" : "memberOf"

    graph_http_request(
      request_method: "GET",
      path: "#{USERS_BASE}/#{user_id}/#{member_of}/microsoft.graph.group",
      query: query_params,
      headers: headers
    )
  end

  def groups_member_of(*args, **opts)
    request = groups_member_of_request(*args, **opts)
    groups_member_of graph_request(request)
  end

  def groups_member_of(response : HTTP::Client::Response)
    GroupQuery.from_json response.body
  end
end
