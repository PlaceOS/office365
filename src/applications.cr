module Office365::Applications
  def list_applications(filter : String? = nil) : Array(Application)
    params = URI::Params.new
    params["$select"] = filter.to_s if filter
    path = "/v1.0/applications"
    response = graph_request(graph_http_request(request_method: "GET", path: path, query: params))
    if response.success?
      Array(Application).from_json(response.body, "value")
    else
      raise "error listing applications #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def get_application(app_id : String, filter : String? = nil) : Application
    params = URI::Params.new
    params["$select"] = filter.to_s if filter
    path = "/v1.0/applications(appId='#{app_id}')"
    response = graph_request(graph_http_request(request_method: "GET", path: path, query: params))
    if response.success?
      Application.from_json(response.body)
    else
      raise "error getting application #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def create_application(app : Application) : Application
    request = graph_http_request(request_method: "POST", path: "/v1.0/applications", data: app.to_json)
    response = graph_request(request)
    if response.success?
      Application.from_json(response.body)
    else
      raise "error creating application #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def delete_application(app_id : String) : Nil
    path = "/v1.0/applications(appId='#{app_id}')"
    response = graph_request(graph_http_request(request_method: "DELETE", path: path))
    raise "error deleting application #{response.status} (#{response.status_code}\n#{response.body}" unless response.success?
  end

  def update_application(app_id : String, body : String) : Nil
    path = "/v1.0/applications(appId='#{app_id}')"
    response = graph_request(graph_http_request(request_method: "PATCH", path: path, data: body))
    raise "error patching application #{response.status} (#{response.status_code}\n#{response.body}" unless response.status_code == 204
  end

  def application_add_pwd(app_id : String, display_name : String, start_date_time : Time? = nil, end_date_time : Time? = nil)
    path = "/v1.0/applications(appId='#{app_id}')/addPassword"
    creds = AppPasswordCredential.new(display_name, start_date_time, end_date_time)
    body = {"passwordCredential": creds}
    request = graph_http_request(request_method: "POST", path: path, data: body.to_json)
    response = graph_request(request)
    if response.success?
      AppPasswordCredential.from_json(response.body)
    else
      raise "error adding application password #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def application_create_sp(app_id : String) : String
    path = "/v1.0/servicePrincipals"
    body = {"appId": app_id}
    request = graph_http_request(request_method: "POST", path: path, data: body.to_json)
    response = graph_request(request)
    if response.success?
      JSON.parse(response.body).as_h["id"].as_s
    else
      raise "error creating application service principal #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def application_get_sp(app_id : String) : String
    params = URI::Params.new
    params["$filter"] = "appId eq '#{app_id}'"
    path = "/v1.0/servicePrincipals"
    response = graph_request(graph_http_request(request_method: "GET", path: path, query: params))
    if response.success?
      JSON.parse(response.body).as_h["value"].as_a.first.as_h["id"].as_s
    else
      raise "error getting application service principal #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def application_upsert_sp(app_id : String) : String
    application_get_sp(app_id) rescue application_create_sp(app_id)
  end

  def application_add_app_role_assignment(app_id : String, role_id : String) : Hash(String, JSON::Any)
    app_sp_id = application_upsert_sp(app_id)
    graph_resource_id = application_get_sp("00000003-0000-0000-c000-000000000000")
    application_add_app_role_assignment(app_sp_id, graph_resource_id, role_id)
  end

  def application_add_app_role_assignment(app_sp_id : String, graph_sp_id : String, role_id : String) : Hash(String, JSON::Any)
    body = {
      "principalId": app_sp_id,
      "resourceId":  graph_sp_id,
      "appRoleId":   role_id,
    }
    path = "/v1.0/servicePrincipals/#{app_sp_id}/appRoleAssignments"
    request = graph_http_request(request_method: "POST", path: path, data: body.to_json)
    response = graph_request(request)
    if response.success?
      JSON.parse(response.body).as_h
    else
      raise "error creating application service app role assignment #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end

  def application_add_oauth2_permission_grant(app_id : String, scope : String) : Hash(String, JSON::Any)
    app_sp_id = application_upsert_sp(app_id)
    graph_resource_id = application_get_sp("00000003-0000-0000-c000-000000000000")
    application_add_oauth2_permission_grant(app_sp_id, graph_resource_id, scope)
  end

  def application_add_oauth2_permission_grant(app_sp_id : String, graph_sp_id : String, scope : String) : Hash(String, JSON::Any)
    body = {
      "clientId":    app_sp_id,
      "consentType": "AllPrincipals",
      "resourceId":  graph_sp_id,
      "scope":       scope,
    }
    path = "/v1.0/oauth2PermissionGrants"
    request = graph_http_request(request_method: "POST", path: path, data: body.to_json)
    response = graph_request(request)
    if response.success?
      JSON.parse(response.body).as_h
    else
      raise "error granting admin consent to delegated permissions #{response.status} (#{response.status_code}\n#{response.body}"
    end
  end
end
