module Office365::Users
  def self.build_select_param(additional_fields : Array(String)? = nil)
    fields = SELECT_FIELDS
    if additional_fields
      fields += additional_fields
    end
    fields.join(",")
  end

  @[AlwaysInline]
  protected def build_select_param(additional_fields : Array(String)? = nil)
    Users.build_select_param(additional_fields)
  end

  def get_user_request(id : String, additional_fields : Array(String)? = nil, **opts)
    query_params = URI::Params.new({
      "$select" => build_select_param(additional_fields),
    }.compact.transform_values { |val| [val] })
    graph_http_request(request_method: "GET", path: "#{USERS_BASE}/#{id}", query: query_params)
  end

  def get_user(*args, **opts)
    request = get_user_request(*args, **opts)
    get_user graph_request(request)
  end

  def get_user(response : HTTP::Client::Response)
    User.from_json response.body
  end

  def get_user_by_mail_request(email : String, additional_fields : Array(String)? = nil, **opts)
    query_params = URI::Params.new({
      "$select" => build_select_param(additional_fields),
      "$filter" => "(mail eq '#{email}') or (userPrincipalName eq '#{email}')",
    }.compact.transform_values { |val| [val] })

    graph_http_request(request_method: "GET", path: "#{USERS_BASE}", query: query_params)
  end

  def get_user_by_mail(*args, **opts)
    request = get_user_by_mail_request(*args, **opts)
    get_user_by_mail graph_request(request)
  end

  def get_user_by_mail(response : HTTP::Client::Response)
    users = UserQuery.from_json response.body
    users.value.first
  end

  def get_user_manager_request(id : String)
    graph_http_request(request_method: "GET", path: "#{USERS_BASE}/#{id}/manager")
  end

  def get_user_manager(*args, **opts)
    request = get_user_manager_request(*args, **opts)
    get_user_manager graph_request(request)
  end

  def get_user_manager(response : HTTP::Client::Response)
    get_user response
  end

  SELECT_FIELDS = %w(id userPrincipalName surname preferredLanguage officeLocation mobilePhone mail jobTitle givenName displayName businessPhones accountEnabled mailNickname)

  def list_users_request(q : String? = nil, limit : Int32? = nil, filter : String? = nil, additional_fields : Array(String)? = nil)
    if q && q.presence
      queries = q.split(" ")
      filter_params = [] of String

      queries.each do |query|
        filter_params << "(startswith(displayName,'#{query}') or startswith(givenName,'#{query}') or startswith(surname,'#{query}') or startswith(mail,'#{query}'))"
      end

      filter_param = "(accountEnabled eq true) and #{filter_params.join(" and ")}"
    elsif filter
      filter_param = filter
    else
      filter_param = "accountEnabled eq true"
    end

    limit = limit.to_s if limit

    query_params = URI::Params.new({
      "$select" => build_select_param(additional_fields),
      # can't use order if there is a filter
      # "$orderby" => "displayName",
      "$filter" => filter_param,
      "$top"    => limit,
    }.compact.transform_values { |val| [val] })

    graph_http_request("GET", "#{USERS_BASE}", query: query_params)
  end

  def list_users(*args, **opts)
    request = list_users_request(*args, **opts)
    response = graph_request(request)

    list_users(response)
  end

  def list_users(response : HTTP::Client::Response)
    UserQuery.from_json response.body
  end

  def create_user_from_json(string_or_io) : User
    request = graph_http_request("POST", "#{USERS_BASE}", data: string_or_io)
    response = graph_request(request)

    get_user(response)
  end

  def update_user_from_json(id, string_or_io)
    request = graph_http_request("PATCH", "#{USERS_BASE}/#{id}", data: string_or_io)
    graph_request(request)
  end

  def delete_user(id : String)
    request = graph_http_request("DELETE", "#{USERS_BASE}/#{id}")
    graph_request(request)
  end

  def list_users_by_query(query : Hash(String, String)? = nil, q : String? = nil)
    # https://graph.microsoft.com/v1.0/f50e8d54-1202-4c05-a58a-4ab4331964d2/users?$filter=id in ('5e44b9ff-b1ff-4656-8b80-6a365ff3dce1', '255bcc9c-354f-4978-8b14-75ed3f6eeb06')

    params = case {query, q}
             in {Hash(String, String), String} then "#{HTTP::Params.encode(query)} and #{q}"
             in {Hash(String, String), Nil}    then "#{HTTP::Params.encode(query)}"
             in {Nil, String}                  then q
             in {Nil, Nil}                     then ""
             end

    request = graph_http_request("GET", USERS_BASE, query: URI::Params.parse(params))
    response = graph_request(request)
    list_users(response)
  end

  def get_invitation(response : HTTP::Client::Response)
    Invitation.from_json response.body
  end

  def invite_user_from_json(string_or_io) : Invitation
    request = graph_http_request("POST", "#{INVITATIONS_BASE}", data: string_or_io)
    response = graph_request(request)

    get_invitation(response)
  end
end
