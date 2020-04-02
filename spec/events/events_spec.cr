require "../spec_helper"

describe Office365::Events do
  describe "#list_events" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_events

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      list = client.list_events(mailbox: "foo@bar.com")
      list.value.size.should eq(1)
      list.value.first.subject.should eq(SpecHelper.mock_event.subject)
    end
  end

  describe "#create_event" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.create_event(**SpecHelper.mock_event_data.merge({mailbox: "foo@bar.com"}))
      event.subject.should eq(SpecHelper.mock_event.subject)
    end
  end

  describe "#get_event" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      event = client.get_event(id: "1234", mailbox: "foo@bar.com")
      event.subject.should eq(SpecHelper.mock_event.subject)
    end
  end

  describe "#update_event" do
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

  describe "#delete_event" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_delete_event

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.delete_event(id: "1234", mailbox: "foo@bar.com").should eq(true)
    end
  end
end
