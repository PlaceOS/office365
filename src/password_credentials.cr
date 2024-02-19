require "time"

module Office365::PasswordCredentials
  def list_application_credentials
    path = "/v1.0/applications(appid='{{@client_id}}')"
    params = URI::Params.new({"$select" => ["passwordCredentials"]})
    response = graph_request(graph_http_request(request_method: "GET", path: path, query: params))
    return nil if response.body.try &.empty?
    JSON.parse(response.body).as_h
  end

  def secret_expiry : Time?
    response = list_application_credentials
    return nil unless response.is_a?(Hash)
    credential = response["passwordCredentials"].as_a?.try &.first?
    return nil unless credential
    end_date_time = credential.as_h["endDateTime"]
    if time = end_date_time.as_s?
      Time::Format::ISO_8601_DATE_TIME.parse(time)
    end
  end
end
