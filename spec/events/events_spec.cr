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
