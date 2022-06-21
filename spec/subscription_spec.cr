require "./spec_helper"

describe Office365::Subscriptions do
  it "creates a subscription" do
    SpecHelper.mock_client_auth

    expires = 2.days.from_now.to_utc

    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/subscriptions")
      .with(body: "{\"resource\":\"/v1.0/users/bob@jane.com/calendar/calendarView\",\"changeType\":\"created,updated\",\"notificationUrl\":\"https://somedomain.com/webhook\",\"expirationDateTime\":\"#{expires.to_rfc3339}\"}", headers: {"Authorization" => "Bearer access_token", "Content-Type" => "application/json", "Prefer" => "IdType=\"ImmutableId\""})
      .to_return(body: %({
        "id": "1234567",
        "changeType": "created,updated",
        "notificationUrl": "https://webhook.azurewebsites.net/api/resourceNotifications",
        "resource": "/users/{id}/messages",
        "expirationDateTime": "2020-03-20T11:00:00.0000000Z"
      })
      )

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    sub = client.create_subscription(
      "/v1.0/users/bob@jane.com/calendar/calendarView",
      Office365::Subscription::Change::Created | Office365::Subscription::Change::Updated,
      "https://somedomain.com/webhook",
      expires
    )

    sub.id.should eq "1234567"
    sub.change_types.should eq "created,updated"
  end

  it "renews a subscription" do
    SpecHelper.mock_client_auth

    expires = 2.days.from_now.to_utc

    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/subscriptions/1234567")
      .with(body: "{\"expirationDateTime\":\"#{expires.to_rfc3339}\"}", headers: {"Authorization" => "Bearer access_token", "Content-Type" => "application/json", "Prefer" => "IdType=\"ImmutableId\""})
      .to_return(body: %({
        "id": "1234567",
        "changeType": "created,updated",
        "notificationUrl": "https://webhook.azurewebsites.net/api/resourceNotifications",
        "resource": "/users/{id}/messages",
        "expirationDateTime": "2020-03-20T11:00:00.0000000Z"
      })
      )

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    sub = client.renew_subscription("1234567", expires)
    sub.id.should eq "1234567"
    sub.change_types.should eq "created,updated"
  end

  it "reauthorize a subscription" do
    SpecHelper.mock_client_auth
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/subscriptions/1234567/reauthorize")
      .to_return(body: "")

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    client.reauthorize_subscription("1234567").should be_true
  end

  it "deletes a subscription" do
    SpecHelper.mock_client_auth
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/subscriptions/1234567")
      .to_return(body: "")

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    client.delete_subscription("1234567").should be_true
  end
end
