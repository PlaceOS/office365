module Office365::Groups
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

  def list_group_members_request(group_id : String, q : String? = nil)
    if q
      queries = q.split(" ")
      filter_params = [] of String

      queries.each do |query|
        filter_params << "(startswith(displayName,'#{query}') or startswith(givenName,'#{query}') or startswith(surname,'#{query}') or startswith(mail,'#{query}'))"
      end

      filter_param = "(accountEnabled eq true) and #{filter_params.join(" and ")}"
    else
      filter_param = "accountEnabled eq true"
    end

    query_params = {
      "$filter" => filter_param,
    }

    graph_http_request(request_method: "GET", path: "/v1.0/groups/#{group_id}/members", query: query_params)
  end

  def list_group_members(*args, **opts)
    request = list_group_members_request(*args, **opts)
    list_group_members graph_request(request)
  end

  def list_group_members(response : HTTP::Client::Response)
    UserQuery.from_json response.body
  end

  # MembersOf Request, what groups a user is in
  def groups_member_of_request(user_id : String, q : String? = nil)
    if q.presence
      filter_param = "displayName:#{q}"
    end

    query_params = {
      "$orderby" => "displayName",
      "$search"  => filter_param,
    }.compact

    graph_http_request(request_method: "GET", path: "/v1.0/users/#{user_id}/memberOf/microsoft.graph.group", query: query_params)
  end

  def groups_member_of(*args, **opts)
    request = groups_member_of_request(*args, **opts)
    groups_member_of graph_request(request)
  end

  def groups_member_of(response : HTTP::Client::Response)
    GroupQuery.from_json response.body
  end
end
