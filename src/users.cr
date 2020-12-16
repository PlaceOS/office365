module Office365::Users
  def get_user_request(id : String)
    graph_http_request(request_method: "GET", path: "/v1.0/users/#{id}")
  end

  def get_user(*args, **opts)
    request = get_user_request(*args, **opts)
    get_user graph_request(request)
  end

  def get_user(response : HTTP::Client::Response)
    User.from_json response.body
  end

  def list_users_request(q : String? = nil, limit : Int32? = nil)
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

    limit = limit.to_s if limit

    query_params = {
      "$filter" => filter_param,
      "$top"    => limit,
    }.compact

    graph_http_request("GET", "/v1.0/users", query: query_params)
  end

  def list_users(*args, **opts)
    request = list_users_request(*args, **opts)
    response = graph_request(request)

    list_users(response)
  end

  def list_users(response : HTTP::Client::Response)
    UserQuery.from_json response.body
  end
end
