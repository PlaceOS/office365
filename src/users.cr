module Office365::Users
  def get_user(id : String)
    response = graph_request(request_method: "GET", path: "/v1.0/users/#{id}")

    if response.success?
      User.from_json response.body
    else
      raise "error fetching user #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def list_users(q : String? = nil, limit : Int32? = nil)
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
      "$top"    => limit,
    }.compact

    response = graph_request("GET", "/v1.0/users", query: query_params)

    if response.success?
      UserQuery.from_json response.body
    else
      raise "error fetching users list #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end
end
