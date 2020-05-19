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

  def mock_token
    Office365::Token.new(
      access_token: "access_token",
      token_type: "token_type",
      expires_in: 12345)
  end

  def mock_user
    Office365::User.from_json(%{{"id":"1234","mail":"foo@bar.com","displayName":"Foo Bar"}})
  end

  def mock_user_query
    Office365::UserQuery.new(value: [mock_user])
  end

  def mock_get_user
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{mock_user.id}")
      .to_return(mock_user.to_json)
  end

  def mock_list_users
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users?%24filter=accountEnabled+eq+true")
      .to_return(mock_user_query.to_json)
  end

  def mock_calendar
    Office365::Calendar.from_json(%{{"id":"1234","name":"Test calendar"}})
  end

  def mock_calendar_query
    Office365::CalendarQuery.new(value: [mock_calendar])
  end

  def mock_list_calendars
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{mock_user.mail}/calendars?")
      .to_return(mock_calendar_query.to_json)
  end

  def mock_list_calendar_groups
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups?%24top=99")
      .to_return(mock_calendar_group_query.to_json)
  end

  def mock_calendar_group
    Office365::CalendarGroup.from_json(%{{"id":"1234","name":"My Calendar Group"}})
  end

  def mock_calendar_group_query
    Office365::CalendarGroupQuery.new(value: [mock_calendar_group])
  end

  def mock_create_calendar
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendars")
      .to_return(mock_calendar.to_json)
  end

  def mock_create_calendar_group
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups")
      .to_return(mock_calendar_group.to_json)
  end

  def mock_delete_calendar
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendars/1234").to_return(body: "")
  end

  def mock_delete_calendar_group
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups/1234").to_return(body: "")
  end

  def mock_get_availability
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/getSchedule")
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
      starts_at: Time.local,
      ends_at:   Time.local + 30.minutes,
      subject:   "My Unique Event Subject",
      rooms:     ["Red Room"],
      attendees: ["elon@musk.com", Office365::EmailAddress.new(address: "david@bowie.net", name: "David Bowie"), Office365::Attendee.new(email: "the@goodies.org")],
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

  def mock_list_events
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events?%24top=100").to_return(mock_event_query_json)
  end

  def mock_create_event
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events").to_return(with_tz(mock_event.to_json))
  end

  def mock_create_event_tz
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events").to_return(with_tz(mock_event_tz.to_json, mock_tz))
  end

  def mock_get_event
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234").to_return(with_tz(mock_event.to_json))
  end

  def mock_get_event_tz
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234").to_return(with_tz(mock_event_tz.to_json, mock_tz))
  end

  def mock_update_event
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/").to_return(with_tz(Office365::Event.new(**mock_event_data.merge(subject: "A Whole New Name!")).to_json))
  end

  def mock_update_event_tz
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/").to_return(with_tz(Office365::Event.new(**mock_event_data_tz.merge(subject: "A Whole New Name!")).to_json, mock_tz))
  end

  def mock_delete_event
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234").to_return(body: "")
  end

  def mock_credentials
    {tenant: "tentant", client_id: "client_id", client_secret: "client_secret"}
  end

  def mock_attachment_data
    {
      id: "123",
      name: "test.txt",
      contentType: "text/plain",
      contentBytes: "aGVsbG8gd29ybGQ=",
      "@odata.type": "#microsoft.graph.fileAttachment",
      "isInline": false,
      size: 217
    }
  end

  def mock_attachment_query_json
    {
      "value" => [mock_attachment_data]
    }.to_json
  end

  def mock_attachment
    Office365::Attachment.from_json(mock_attachment_data.to_json)
  end

  def mock_list_attachments
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234/attachments?%24top=100").to_return(mock_attachment_query_json)
  end

  def mock_create_attachment
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234/attachments").to_return(mock_attachment_data.to_json)
  end

  def mock_get_attachment
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234/attachments/1234").to_return(mock_attachment_data.to_json)
  end

  def mock_delete_attachment
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234/attachments/1234").to_return(body: "")
  end
end

Spec.before_each do
  WebMock.reset
end
