module Office365::Subscriptions
  def create_subscription_request(
    resource : String,
    change_types : Subscription::Change,
    notification_url : String,
    expiration_date_time : Time,
    client_state : String? = nil,
    lifecycle_notification_url : String? = nil,
    **opts
  )
    sub = Subscription.new(resource, change_types, notification_url, expiration_date_time, client_state, lifecycle_notification_url)
    graph_http_request(request_method: "POST", path: "/v1.0/subscriptions", data: sub.to_json)
  end

  def create_subscription(*args, **opts)
    request = create_subscription_request(*args, **opts)
    response = graph_request(request)
    create_subscription(response)
  end

  def create_subscription(response : HTTP::Client::Response)
    Subscription.from_json response.body
  end

  # renew a subscription
  def renew_subscription_request(
    subscription_id : String,
    expiration_date_time : Time
  )
    graph_http_request(
      request_method: "PATCH",
      path: "/v1.0/subscriptions/#{subscription_id}",
      data: {expirationDateTime: expiration_date_time.to_utc}.to_json
    )
  end

  def renew_subscription(*args, **opts)
    request = renew_subscription_request(*args, **opts)
    response = graph_request(request)
    renew_subscription(response)
  end

  def renew_subscription(response : HTTP::Client::Response)
    create_subscription(response)
  end

  # Parse validation token sent to test the notification URL
  # POST https://{notificationUrl}?validationToken={opaqueTokenCreatedByMicrosoftGraph}
  # Repond with 200 OK, content type of text/plain, decoded validationToken

  # reauthorize a subscription
  # Life cycle notification to reauthorize, respond with a 202 Accepted (check client state matches)
  def reauthorize_subscription_request(subscription_id : String)
    graph_http_request(
      request_method: "POST",
      path: "/v1.0/subscriptions/#{subscription_id}/reauthorize",
    )
  end

  def reauthorize_subscription(*args, **opts)
    request = reauthorize_subscription_request(*args, **opts)
    reauthorize_subscription graph_request(request)
  end

  def reauthorize_subscription(response : HTTP::Client::Response)
    true
  end

  def delete_subscription_request(subscription_id : String)
    graph_http_request(
      request_method: "DELETE",
      path: "/v1.0/subscriptions/#{subscription_id}",
    )
  end

  def delete_subscription(*args, **opts)
    request = delete_subscription_request(*args, **opts)
    delete_subscription graph_request(request)
  end

  def delete_subscription(response : HTTP::Client::Response)
    true
  end
end
