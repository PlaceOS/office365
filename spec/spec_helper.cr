require "json"
require "spec"
require "webmock"
require "../src/office365"

module SpecHelper
  extend self

  def mock_client_auth
    WebMock.stub(:post, "https://login.microsoftonline.com/#{mock_credentials[:tenant]}/oauth2/v2.0/token")
      .to_return(mock_token.to_json)
  end

  def mock_delegated_client_auth
    WebMock.stub(:post, "https://login.microsoftonline.com/tentant/oauth2/v2.0/token")
      .with(body: "client_id=client_id&response_type=code&scope=user.read+mail.read", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
      .to_return({code: "M0ab92efe-b6fd-df08-87dc-2c6500a7f84d"}.to_json)

    WebMock.stub(:post, "https://login.microsoftonline.com/tentant/oauth2/v2.0/token")
      .with(body: "client_id=client_id&scope=user.read+mail.read&client_secret=client_secret&grant_type=client_credentials&code=M0ab92efe-b6fd-df08-87dc-2c6500a7f84d", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
      .to_return(mock_token.to_json)
  end

  def mock_token
    Office365::Token.new(
      access_token: "access_token",
      token_type: "token_type",
      expires_in: 12345)
  end

  def mock_mail
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/1234/sendMail")
      .with(body: "{\"message\":{\"subject\":\"subject\",\"body\":{\"contentType\":\"Text\",\"content\":\"body\"}}}", headers: {"Authorization" => "Bearer access_token", "Content-type" => "application/json", "Prefer" => "IdType=\"ImmutableId\""})
      .to_return(body: "")
  end

  def mock_create_user_request_body
    {
      accountEnabled:    true,
      displayName:       "Adele Vance",
      mailNickname:      "AdeleV",
      userPrincipalName: "adelevancetest@testing.onmicrosoft.com",
      passwordProfile:   {
        forceChangePasswordNextSignIn: true,
        password:                      "xWwvJ]6NMw+bWH-d",
      },
    }
  end

  def mock_invite_user_request_body
    {
      invitedUserEmailAddress: "foo@bar.com",
      inviteRedirectUrl: "https://spec.example.com",
    }
  end

  def mock_update_user_request_body
    {
      displayName: "Maria Valance",
    }
  end

  def mock_user
    Office365::User.from_json(%({"id":"1234","mail":"foo@bar.com","displayName":"Foo Bar","userPrincipalName":"foo@bar.com","businessPhones":[]}))
  end

  def mock_user2
    Office365::User.from_json(%({"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","id":"0faa49e2-0602-41c2-8a7b-1438333c0af1","businessPhones":[],"displayName":"Adele Vance","givenName":null,"jobTitle":null,"mail":null,"mobilePhone":null,"officeLocation":null,"preferredLanguage":null,"surname":null,"userPrincipalName":"adelevancetest@testing.onmicrosoft.com"}))
  end

  def mock_invitation
    Office365::Invitation.from_json({
      invitedUserDisplayName: "",
      invitedUserEmailAddress: "foo@bar.com",
      invitedUserMessageInfo: {
        ccRecipients: [] of NamedTuple(emailAddress: NamedTuple(address: String, name: String)),
        customizedMessageBody: "",
        messageLanguage: "en-US",
      },
      sendInvitationMessage: false,
      inviteRedirectUrl: "https://spec.example.com",
      inviteRedeemUrl: "graph.ms.example.com/qwerty",
      invitedUserType: "Guest",
      status: "PendingAcceptance",
      invitedUser: mock_user2,
    }.to_json)
  end

  def mock_create_user
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users")
      .with(body: mock_create_user_request_body.to_json)
      .to_return(body: mock_user2.to_json)
  end

  def mock_invite_user
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/invitations")
      .with(body: mock_invite_user_request_body.to_json)
      .to_return(body: mock_invitation.to_json)
  end

  def mock_update_user
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/0faa49e2-0602-41c2-8a7b-1438333c0af1")
      .with(body: mock_update_user_request_body.to_json)
      .to_return(status: 204)
  end

  def mock_delete_user
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/0faa49e2-0602-41c2-8a7b-1438333c0af1")
      .to_return(status: 204)
  end

  def mock_user_query
    Office365::UserQuery.new(value: [mock_user])
  end

  def mock_get_user
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{URI.encode_path mock_user.id}")
      .to_return(mock_user.to_json)
  end

  def mock_list_users
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users?$filter=accountEnabled eq true")
      .to_return(mock_user_query.to_json)
  end

  def mock_list_users_with_query
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users?$filter=(id in ('1234-5678-9012', '1234-5678-5435'))")
      .to_return(mock_user_query.to_json)
  end

  def mock_group
    Office365::Group.from_json(%({"id":"1234-5678-9012","visibility":"Public","displayName":"Group Name","mailEnabled":false}))
  end

  def mock_group_query
    Office365::GroupQuery.new(value: [mock_group])
  end

  def mock_get_group
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/groups/#{URI.encode_path mock_group.id}")
      .to_return(mock_group.to_json)
  end

  def mock_list_group_members
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/groups/1234-5678-9012/members/microsoft.graph.user?$orderby=displayName&$top=999")
      .to_return(mock_user_query.to_json)
  end

  def mock_groups_member_of
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{URI.encode_path mock_user.id}/transitiveMemberOf/microsoft.graph.group?$orderby=displayName&$top=999")
      .to_return(mock_group_query.to_json)
  end

  def mock_list_groups
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/groups?$filter=startswith(displayName, 'query')&$top=950")
      .to_return(mock_group_query.to_json)
  end

  def mock_calendar
    Office365::Calendar.from_json(%({"id":"1234","name":"Test calendar"}))
  end

  def mock_calendar_query
    Office365::CalendarQuery.new(value: [mock_calendar])
  end

  def mock_list_calendars
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{URI.encode_path mock_user.mail.to_s}/calendars?")
      .to_return(mock_calendar_query.to_json)
  end

  def mock_list_calendar_groups
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendarGroups?$top=99")
      .to_return(mock_calendar_group_query.to_json)
  end

  def mock_calendar_group
    Office365::CalendarGroup.from_json(%({"id":"1234","name":"My Calendar Group"}))
  end

  def mock_calendar_group_query
    Office365::CalendarGroupQuery.new(value: [mock_calendar_group])
  end

  def mock_create_calendar
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendars")
      .to_return(mock_calendar.to_json)
  end

  def mock_create_calendar_group
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendarGroups")
      .to_return(mock_calendar_group.to_json)
  end

  def mock_delete_calendar
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendars/1234").to_return(body: "")
  end

  def mock_delete_calendar_group
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendarGroups/1234").to_return(body: "")
  end

  def mock_get_availability
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/getSchedule")
      .to_return(mock_availability.to_json)
  end

  def mock_availability
    {
      "value" => [
        {
          "scheduleId"    => "foo@bar.com",
          "scheduleItems" => [
            {
              "status" => "busy",
              "start"  => {
                "dateTime" => "2020-05-10T23:49:00.0000000",
                "timeZone" => "UTC",
              },
              "end" => {
                "dateTime" => "2020-05-11T00:49:00.0000000",
                "timeZone" => "UTC",
              },
            },
          ],
        },
      ],
    }
  end

  def mock_event_data
    {
      starts_at:       Time.local,
      ends_at:         Time.local + 30.minutes,
      subject:         "My Unique Event Subject",
      rooms:           ["Red Room"],
      attendees:       ["elon%40musk.com", Office365::EmailAddress.new(address: "david%40bowie.net", name: "David Bowie"), Office365::Attendee.new(email: "the%40goodies.org")],
      response_status: Office365::ResponseStatus.new(response: Office365::ResponseStatus::Response::Organizer, time: "0001-01-01T00:00:00Z"),
    }
  end

  def mock_tz
    "America/New_York"
  end

  def mock_event_data_tz
    location = Time::Location.load(mock_tz)
    {
      starts_at: Time.local(location: location),
      ends_at:   Time.local(location: location) + 30.minutes,
      subject:   "My Unique Event Subject",
      rooms:     ["Red Room"],
      attendees: ["elon@musk.com", Office365::EmailAddress.new(address: "david@bowie.net", name: "David Bowie"), Office365::Attendee.new(email: "the@goodies.org")],
    }
  end

  def with_tz(event, tz : String = "UTC")
    event_response = JSON.parse(event).as_h
    event_response.merge({"originalStartTimeZone" => tz}).to_json
  end

  def mock_event
    Office365::Event.new(**mock_event_data)
  end

  def mock_event_tz
    Office365::Event.new(**mock_event_data_tz)
  end

  def mock_event_query_json
    {
      "value" => [JSON.parse(with_tz(mock_event.to_json))],
    }.to_json
  end

  def mock_event_query_json_error
    {
      "error": {
        "code":       "invalidRange",
        "message":    "Uploaded fragment overlaps with existing data.",
        "innerError": {
          "requestId": "request-id",
          "date":      "date-time",
        },
      },
    }.to_json
  end

  def mock_batch_event_list_json
    {
      "responses" => [
        {
          "id"     => 0,
          "status" => 200,
          "body"   => {
            "%40odata.context" => "https://graph.microsoft.com/v1.0/$metadata#users('7bb44254-ffeb-4040-84bb-8c2783f726e8')/calendar/calendarView",
            "value"            => [JSON.parse(with_tz(mock_event.to_json))],
          },
        },
        {
          "id"     => 1,
          "status" => 200,
          "body"   => JSON.parse(with_tz(mock_event.to_json)),
        },
      ],
    }.to_json
  end

  def mock_list_events
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/calendarView?startDateTime=2020-01-01T00:00:00-00:00&endDateTime=2020-06-01T00:00:00-00:00&$top=10000").to_return(mock_event_query_json)
  end

  def mock_list_events_error
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/bar%40foo.com/calendar/calendarView?startDateTime=2020-01-01T00:00:00-00:00&endDateTime=2020-06-01T00:00:00-00:00&$top=10000")
      .to_return(mock_event_query_json_error)
  end

  def mock_batch_list_events
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/%24batch").to_return(mock_batch_event_list_json)
  end

  def mock_create_event
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events").to_return(with_tz(mock_event.to_json))
  end

  def mock_create_event_tz
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events").to_return(with_tz(mock_event_tz.to_json, mock_tz))
  end

  def mock_get_event
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234").to_return(with_tz(mock_event.to_json))
  end

  def mock_get_event_tz
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234").to_return(with_tz(mock_event_tz.to_json, mock_tz))
  end

  def mock_update_event
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/").to_return(with_tz(Office365::Event.new(**mock_event_data.merge(subject: "A Whole New Name!")).to_json))
  end

  def mock_update_event_tz
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/").to_return(with_tz(Office365::Event.new(**mock_event_data_tz.merge(subject: "A Whole New Name!")).to_json, mock_tz))
  end

  def mock_delete_event
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234").to_return(body: "")
  end

  def mock_decline_event
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/decline").to_return(body: "")
  end

  def mock_credentials
    {tenant: "tentant", client_id: "client_id", client_secret: "client_secret"}
  end

  def mock_attachment_data
    {
      id:            "123",
      name:          "test.txt",
      contentType:   "text/plain",
      contentBytes:  "aGVsbG8gd29ybGQ=",
      "@odata.type": "#microsoft.graph.fileAttachment",
      "isInline":    false,
      size:          217,
    }
  end

  def mock_attachment_query_json
    {
      "value" => [mock_attachment_data],
    }.to_json
  end

  def mock_attachment
    Office365::Attachment.from_json(mock_attachment_data.to_json)
  end

  def mock_list_attachments
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/attachments?$top=100").to_return(mock_attachment_query_json)
  end

  def mock_create_attachment
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/attachments").to_return(mock_attachment_data.to_json)
  end

  def mock_get_attachment
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/attachments/1234").to_return(mock_attachment_data.to_json)
  end

  def mock_delete_attachment
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/attachments/1234").to_return(body: "")
  end
end

Spec.before_each do
  WebMock.reset
end
