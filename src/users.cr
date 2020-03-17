module Office365
  module Users

    def get_users(q : String? = nil, limit : Int32? = nil)
      if q 
        queries = q.split(" ")
        filter_params = [] of String

        queries.each do |q|
          filter_params << "(startswith(displayName,'#{q}') or startswith(givenName,'#{q}') or startswith(surname,'#{q}') or startswith(mail,'#{q}'))"
        end

        filter_param = "(accountEnabled eq true) and #{filter_params.join(" and ")}"
      else
        filter_param = "accountEnabled eq true"
      end

      query_params = {
        "$filter" => filter_param,
        "$top"    => limit
      }.compact

      response = graph_request("GET", "/v1.0/users", query: query_params)

      if response.success?
        UserQuery.from_json response.body
      else
        raise "error fetching users list #{response.status} (#{response.status_code}\n#{response.body}"
      end
    end

  end
end
