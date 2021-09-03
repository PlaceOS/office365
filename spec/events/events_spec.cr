require "../spec_helper"

describe Office365::Events do
  describe "#list_events" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_events

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      list = client.list_events(mailbox: "foo@bar.com", period_start: Time.utc(2020, 1, 1, 0, 0), period_end: Time.utc(2020, 6, 1, 0, 0))
      list.value.size.should eq(1)
      list.value.first.subject.should eq(SpecHelper.mock_event.subject)
    end
    it "succeeds when everything goes well when we batch requests" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_events
      SpecHelper.mock_batch_list_events

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      request_1 = client.list_events_request(mailbox: "foo@bar.com", period_start: Time.utc(2020, 1, 1, 0, 0), period_end: Time.utc(2020, 6, 1, 0, 0))
      request_2 = client.get_event_request(id: "1234", mailbox: "foo@bar.com")
      results = client.batch({request_1, request_2})
      list = client.list_events(results[request_1])
      list.value.size.should eq(1)
      list.value.first.subject.should eq(SpecHelper.mock_event.subject)
      event = client.get_event(results[request_2])
      event.subject.should eq(SpecHelper.mock_event.subject)
      event.response_status.not_nil!.response.should eq(SpecHelper.mock_event.response_status.not_nil!.response)
    end

    it "raises an error when query is incorrectly formatted" do
      expect_raises(JSON::Error) do
        SpecHelper.mock_client_auth
        SpecHelper.mock_list_events_error

        client = Office365::Client.new(**SpecHelper.mock_credentials)
        client.list_events(mailbox: "bar@foo.com", period_start: Time.utc(2020, 1, 1, 0, 0), period_end: Time.utc(2020, 6, 1, 0, 0))
      end
    end
  end

  describe "#create_event UTC" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.create_event(**SpecHelper.mock_event_data.merge({mailbox: "foo@bar.com"}))
      event.subject.should eq(SpecHelper.mock_event.subject)
    end
  end

  describe "#create_event with tz" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_event_tz

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.create_event(**SpecHelper.mock_event_data.merge({mailbox: "foo@bar.com"}))
      event.timezone.should eq(SpecHelper.mock_tz)
      event.starts_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
      event.ends_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
    end
  end

  describe "#get_event UTC" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.get_event(id: "1234", mailbox: "foo@bar.com")
      event.subject.should eq(SpecHelper.mock_event.subject)
      event.response_status.not_nil!.response.should eq(SpecHelper.mock_event.response_status.not_nil!.response)
    end
  end

  describe "#get_event with tz" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_event_tz

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.get_event(id: "1234", mailbox: "foo@bar.com")
      event.timezone.should eq(SpecHelper.mock_tz)
      event.starts_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
      event.ends_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
    end
  end

  describe "#update_event UTC" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_update_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = SpecHelper.mock_event
      event.subject = "A Whole New Name!"
      updated_event = client.update_event(event: event, mailbox: "foo@bar.com")
      event.subject.should eq(updated_event.subject)
    end
  end

  describe "#update_event with tz" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_update_event_tz

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = SpecHelper.mock_event_tz
      event.subject = "A Whole New Name!"
      updated_event = client.update_event(event: event, mailbox: "foo@bar.com")
      updated_event.timezone.should eq(SpecHelper.mock_tz)
      updated_event.starts_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
      updated_event.ends_at.not_nil!.location.to_s.should eq(SpecHelper.mock_tz)
    end
  end

  describe "#delete_event" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_delete_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.delete_event(id: "1234", mailbox: "foo@bar.com").should eq(true)
    end
  end
end
