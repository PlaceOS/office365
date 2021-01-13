module Office365::Mail
  def send_mail_request(id : String, message : Message)
    graph_http_request(request_method: "POST", path: "/v1.0/users/#{id}/sendMail", data: {message: message}.to_json)
  end

  def send_mail(*args, **opts)
    request = send_mail_request(*args, **opts)
    send_mail graph_request(request)
  end

  # returns 202 Accepted with no body
  def send_mail(response : HTTP::Client::Response)
    response.success? ? true : false
  end
end
