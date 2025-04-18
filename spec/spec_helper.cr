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
      inviteRedirectUrl:       "https://spec.example.com",
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

  def mock_user2_data
    {
      "@odata.context":    "https://graph.microsoft.com/v1.0/$metadata#users/$entity",
      "id":                "0faa49e2-0602-41c2-8a7b-1438333c0af1",
      "businessPhones":    [] of String,
      "displayName":       "Adele Vance",
      "givenName":         nil,
      "jobTitle":          nil,
      "mail":              nil,
      "mobilePhone":       nil,
      "officeLocation":    nil,
      "preferredLanguage": nil,
      "surname":           nil,
      "userPrincipalName": "adelevancetest@testing.onmicrosoft.com",
    }
  end

  def mock_user2
    Office365::User.from_json(mock_user2_data.to_json)
  end

  def mock_invitation
    Office365::Invitation.from_json({
      invitedUserDisplayName:  "",
      invitedUserEmailAddress: "foo@bar.com",
      invitedUserMessageInfo:  {
        ccRecipients:          [] of NamedTuple(emailAddress: NamedTuple(address: String, name: String)),
        customizedMessageBody: "",
        messageLanguage:       "en-US",
      },
      sendInvitationMessage: false,
      inviteRedirectUrl:     "https://spec.example.com",
      inviteRedeemUrl:       "graph.ms.example.com/qwerty",
      invitedUserType:       "Guest",
      status:                "PendingAcceptance",
      invitedUser:           mock_user2,
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
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users?$select=id,userPrincipalName,surname,preferredLanguage,officeLocation,mobilePhone,mail,jobTitle,givenName,displayName,businessPhones,accountEnabled,mailNickname&$filter=accountEnabled eq true")
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
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/groups/1234-5678-9012/members/microsoft.graph.user?$select=id,userPrincipalName,surname,preferredLanguage,officeLocation,mobilePhone,mail,jobTitle,givenName,displayName,businessPhones,accountEnabled,mailNickname&$orderby=displayName&$top=999")
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
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/calendarView?startDateTime=2020-01-01T00%3A00%3A00-00%3A00&endDateTime=2020-06-01T00%3A00%3A00-00%3A00&%24top=10000").to_return(mock_event_query_json)
  end

  def mock_list_events_error
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/bar%40foo.com/calendar/calendarView?startDateTime=2020-01-01T00%3A00%3A00-00%3A00&endDateTime=2020-06-01T00%3A00%3A00-00%3A00&%24top=10000")
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

  def mock_accept_event
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo%40bar.com/calendar/events/1234/accept").to_return(body: "")
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

  def mock_list_application(expiry = true)
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/applications%28appid%3D%27%7B%7B%40client_id%7D%7D%27%29?%24select=passwordCredentials")
      .to_return(body: mock_pwd_cred_data(expiry).to_json)
  end

  def mock_pwd_cred_data(expiry = true)
    {
      "@odata.context":      "https://graph.microsoft.com/v1.0/$metadata#applications(passwordCredentials)/$entity",
      "passwordCredentials": [
        {
          "customKeyIdentifier": nil,
          "displayName":         "Some Name",
          "endDateTime":         expiry ? "2025-03-12T23:44:20.176Z" : nil,
          "hint":                "HIN",
          "keyId":               "0002dcce-acca-41b5-94d9-60932f151eaf",
          "secretText":          nil,
          "startDateTime":       "2023-03-13T23:44:20.176Z",
        },
      ],
    }
  end

  def mock_list_room
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.room")
      .to_return(body: mock_list_rooms_data.to_json)
  end

  def mock_list_room_list
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/places/microsoft.graph.roomList")
      .to_return(body: mock_list_room_list_data.to_json)
  end

  def mock_list_rooms_data
    {
      "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#places/microsoft.graph.room",
      "value":          [
        {
          "id":           "3162F1E1-C4C0-604B-51D8-91DA78989EB1",
          "emailAddress": "cf100@contoso.com",
          "displayName":  "Conf Room 100",
          "address":      {
            "street":          "4567 Main Street",
            "city":            "Buffalo",
            "state":           "NY",
            "postalCode":      "98052",
            "countryOrRegion": "USA",
          },
          "geoCoordinates": {
            "latitude":  47.640568390488626,
            "longitude": -122.1293731033803,
          },
          "phone":                  "000-000-0000",
          "nickname":               "Conf Room",
          "label":                  "100",
          "capacity":               50,
          "building":               "1",
          "floorNumber":            1,
          "isManaged":              true,
          "isWheelChairAccessible": false,
          "bookingType":            "standard",
          "tags":                   [
            "bean bags",
          ],
          "audioDeviceName": nil,
          "videoDeviceName": nil,
          "displayDevice":   "surface hub",
        },
        {
          "id":           "3162F1E1-C4C0-604B-51D8-91DA78970B97",
          "emailAddress": "cf200@contoso.com",
          "displayName":  "Conf Room 200",
          "address":      {
            "street":          "4567 Main Street",
            "city":            "Buffalo",
            "state":           "NY",
            "postalCode":      "98052",
            "countryOrRegion": "USA",
          },
          "geoCoordinates": {
            "latitude":  47.640568390488625,
            "longitude": -122.1293731033802,
          },
          "phone":                  "000-000-0000",
          "nickname":               "Conf Room",
          "label":                  "200",
          "capacity":               40,
          "building":               "2",
          "floorNumber":            2,
          "isManaged":              true,
          "isWheelChairAccessible": false,
          "bookingType":            "standard",
          "tags":                   [
            "benches",
            "nice view",
          ],
          "audioDeviceName": nil,
          "videoDeviceName": nil,
          "displayDevice":   "surface hub",
        },
      ],
    }
  end

  def mock_list_room_list_data
    {
      "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#places/microsoft.graph.roomList",
      "value":          [
        {
          "id":          "DC404124-302A-92AA-F98D-7B4DEB0C1705",
          "displayName": "Building 1",
          "address":     {
            "street":          "4567 Main Street",
            "city":            "Buffalo",
            "state":           "NY",
            "postalCode":      "98052",
            "countryOrRegion": "USA",
          },
          "geocoordinates": nil,
          "phone":          nil,
          "emailAddress":   "bldg1@contoso.com",
        },
        {
          "id":          "DC404124-302A-92AA-F98D-7B4DEB0C1706",
          "displayName": "Building 2",
          "address":     {
            "street":          "4567 Main Street",
            "city":            "Buffalo",
            "state":           "NY",
            "postalCode":      "98052",
            "countryOrRegion": "USA",
          },
          "geocoordinates": nil,
          "phone":          nil,
          "emailAddress":   "bldg2@contoso.com",
        },
      ],
    }
  end

  def mock_get_room
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/places/979e9793-3e91-40eb-b18c-0ea937893956")
      .to_return(body: mock_get_room_data.to_json)
  end

  def mock_get_room_list
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/places/Building2Rooms%40contoso.com")
      .to_return(body: mock_get_room_data.to_json)
  end

  def mock_get_room_data
    {
      "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#places/$entity",
      "@odata.type":    "#microsoft.graph.roomList",
      "id":             "979e9793-3e91-40eb-b18c-0ea937893956",
      "displayName":    "Building 2 Rooms",
      "address":        nil,
      "geoCoordinates": nil,
      "phone":          "",
      "emailAddress":   "Building2Rooms@contoso.com",
    }
  end

  def mock_get_room_in_room_list
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/places/Building2Rooms%40contoso.com/microsoft.graph.roomlist/rooms")
      .to_return(body: mock_get_room_in_room_list_data.to_json)
  end

  def mock_get_room_in_room_list_data
    {
      "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#places('Building2Rooms%40contoso.com')/microsoft.graph.roomList/rooms",
      "value":          [
        {
          "id":                     "f4119db7-9a33-4bfe-a387-4444b9e7fd54",
          "displayName":            "Conf Room Rainier",
          "address":                nil,
          "geoCoordinates":         nil,
          "phone":                  "",
          "nickname":               "Conf Room Rainier",
          "emailAddress":           "Rainier@contoso.com",
          "building":               nil,
          "floorNumber":            nil,
          "floorLabel":             nil,
          "label":                  nil,
          "capacity":               nil,
          "bookingType":            "standard",
          "audioDeviceName":        nil,
          "videoDeviceName":        nil,
          "displayDeviceName":      nil,
          "isWheelChairAccessible": false,
          "tags":                   ["some_tag"],
        },
        {
          "id":                     "42385a28-1a16-4043-8d84-07615656c4e3",
          "displayName":            "Conf Room Hood",
          "address":                nil,
          "geoCoordinates":         nil,
          "phone":                  "",
          "nickname":               "Conf Room Hood",
          "emailAddress":           "Hood@contoso.com",
          "building":               nil,
          "floorNumber":            nil,
          "floorLabel":             nil,
          "label":                  nil,
          "capacity":               nil,
          "bookingType":            "standard",
          "audioDeviceName":        nil,
          "videoDeviceName":        nil,
          "displayDeviceName":      nil,
          "isWheelChairAccessible": false,
          "tags":                   ["some_tag"],
        },
        {
          "id":                     "850ee91e-a154-4d87-928e-da04c788fd90",
          "displayName":            "Conf Room Baker",
          "address":                nil,
          "geoCoordinates":         nil,
          "phone":                  "",
          "nickname":               "Conf Room Baker",
          "emailAddress":           "Baker@contoso.com",
          "building":               nil,
          "floorNumber":            nil,
          "floorLabel":             nil,
          "label":                  nil,
          "capacity":               nil,
          "bookingType":            "standard",
          "audioDeviceName":        nil,
          "videoDeviceName":        nil,
          "displayDeviceName":      nil,
          "isWheelChairAccessible": false,
          "tags":                   ["some_tag"],
        },
      ],
    }
  end

  def mock_list_channel_msgs
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/teams/fbe2bf47-16c8-47cf-b4a5-4b9b187c508b/channels/19%3A4a95f7d8db4c4e7fae857bcebe0623e6%40thread.tacv2/messages?%24top=3")
      .to_return(body: mock_list_channel_messages)
  end

  def mock_list_channel_messages
    File.read("spec/chat_messages/messages.json")
  end

  def mock_get_channel_msg
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/teams/fbe2bf47-16c8-47cf-b4a5-4b9b187c508b/channels/19%3A4a95f7d8db4c4e7fae857bcebe0623e6%40thread.tacv2/messages/1614618259349")
      .to_return(body: mock_get_channel_message)
  end

  def mock_get_channel_message
    %(
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#chats('19%3A8ea0e38b-efb3-4757-924a-5f94061cf8c2_97f62344-57dc-409c-88ad-c4af14158ff5%40unq.gbl.spaces')/messages/$entity",
    "id": "1612289992105",
    "replyToId": null,
    "etag": "1612289992105",
    "messageType": "message",
    "createdDateTime": "2021-02-02T18:19:52.105Z",
    "lastModifiedDateTime": "2021-02-02T18:19:52.105Z",
    "lastEditedDateTime": null,
    "deletedDateTime": null,
    "subject": null,
    "summary": null,
    "chatId": "19:8ea0e38b-efb3-4757-924a-5f94061cf8c2_97f62344-57dc-409c-88ad-c4af14158ff5@unq.gbl.spaces",
    "importance": "normal",
    "locale": "en-us",
    "webUrl": null,
    "channelIdentity": null,
    "policyViolation": null,
    "eventDetail": null,
    "from": {
        "application": null,
        "device": null,
        "conversation": null,
        "user": {
            "@odata.type": "#microsoft.graph.teamworkUserIdentity",
            "id": "8ea0e38b-efb3-4757-924a-5f94061cf8c2",
            "displayName": "Robin Kline",
            "userIdentityType": "aadUser",
            "tenantId": "e61ef81e-8bd8-476a-92e8-4a62f8426fca"
        }
    },
    "body": {
        "contentType": "text",
        "content": "test"
    },
    "attachments": [],
    "mentions": [],
    "reactions": [],
    "messageHistory": []
}
    )
  end

  def mock_channel_send_msg
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/teams/fbe2bf47-16c8-47cf-b4a5-4b9b187c508b/channels/19%3A4a95f7d8db4c4e7fae857bcebe0623e6%40thread.tacv2/messages")
      .with(body: "{\"body\":{\"content\":\"test\",\"contentType\":\"TEXT\"}}", headers: {"Authorization" => "Bearer access_token", "Content-Type" => "application/json", "Prefer" => "IdType=\"ImmutableId\""})
      .to_return(status: 201, body: mock_get_channel_message)
  end

  def mock_list_applications
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/applications")
      .to_return(body: mock_list_applications_resp)
  end

  def mock_create_applications
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/applications")
      .to_return(body: mock_create_application_resp)
  end

  def mock_applications_add_pwd
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/applications/my-app/addPassword")
      .to_return(body: mock_application_add_pwd_resp)
  end

  def mock_get_application_id_and_web
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/applications%28appId%3D%27my-app%27%29?%24select=id%2Cweb")
      .to_return(body: mock_get_app_id_and_web_resp)
  end

  def mock_list_applications_resp
    %(
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#applications",
  "value": [
    {
      "appId": "00000000-0000-0000-0000-000000000000",
      "identifierUris": [ "http://contoso/" ],
      "displayName": "My app",
      "publisherDomain": "contoso.com",
      "signInAudience": "AzureADMyOrg"
    }
  ]
}
    )
  end

  def mock_create_application_resp
    %(
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#applications/$entity",
    "id": "03ef14b0-ca33-4840-8f4f-d6e91916010e",
    "deletedDateTime": null,
    "isFallbackPublicClient": null,
    "appId": "631a96bc-a705-4eda-9f99-fdaf9f54f6a2",
    "applicationTemplateId": null,
    "identifierUris": [],
    "createdDateTime": "2019-09-17T19:10:35.2742618Z",
    "displayName": "Display name",
    "isDeviceOnlyAuthSupported": null,
    "groupMembershipClaims": null,
    "optionalClaims": null,
    "addIns": [],
    "publisherDomain": "contoso.com",
    "samlMetadataUrl": "https://graph.microsoft.com/2h5hjaj542de/app",
    "signInAudience": "AzureADandPersonalMicrosoftAccount",
    "tags": [],
    "tokenEncryptionKeyId": null,
    "api": {
        "requestedAccessTokenVersion": 2,
        "acceptMappedClaims": null,
        "knownClientApplications": [],
        "oauth2PermissionScopes": [],
        "preAuthorizedApplications": []
    },
    "appRoles": [],
    "publicClient": {
        "redirectUris": []
    },
    "info": {
        "termsOfServiceUrl": null,
        "supportUrl": null,
        "privacyStatementUrl": null,
        "marketingUrl": null,
        "logoUrl": null
    },
    "keyCredentials": [],
    "parentalControlSettings": {
        "countriesBlockedForMinors": [],
        "legalAgeGroupRule": "Allow"
    },
    "passwordCredentials": [],
    "requiredResourceAccess": [],
    "web": {
        "redirectUris": [],
        "homePageUrl": null,
        "logoutUrl": null,
        "implicitGrantSettings": {
            "enableIdTokenIssuance": false,
            "enableAccessTokenIssuance": false
        }
    }
}

)
  end

  def mock_application_add_pwd_resp
    %(
{
    "customKeyIdentifier": null,
    "endDateTime": "2021-09-09T19:50:29.3086381Z",
    "keyId": "f0b0b335-1d71-4883-8f98-567911bfdca6",
    "startDateTime": "2019-09-09T19:50:29.3086381Z",
    "secretText": "[6gyXA5S20@MN+WRXAJ]I-TO7g1:h2P8",
    "hint": "[6g",
    "displayName": "Password friendly name"
}
)
  end

  def mock_get_app_id_and_web_resp
    %(
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#applications(id,web)/$entity",
  "id": "870cf357-927e-4d71-9f81-6ca278227636",
  "web": {
    "homePageUrl": null,
    "logoutUrl": "https://localhost/auth/logout",
    "redirectUris": [
      "https://example.com",
      "https://mydomain.com/auth/login"
    ],
    "implicitGrantSettings": {
      "enableAccessTokenIssuance": false,
      "enableIdTokenIssuance": false
    },
    "redirectUriSettings": [
      {
        "uri": "https:/localhost:8843",
        "index": null
      },
      {
        "uri": "https://localhost:8843/auth/login",
        "index": null
      }
    ]
  }
}
)
  end
end

Spec.before_each do
  WebMock.reset
end
