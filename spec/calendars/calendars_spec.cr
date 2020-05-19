require "../spec_helper"

describe Office365::Calendars do
  describe "#list_calendars" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_calendars

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      calendar_list = client.list_calendars(mailbox: "foo@bar.com")
      calendar_list.value.size.should eq(1)
      calendar_list.value.first.name.should eq(SpecHelper.mock_calendar.name)
    end
  end

  describe "#list_calendar_groups" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_calendar_groups

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      list = client.list_calendar_groups(mailbox: "foo@bar.com")
      list.is_a?(Office365::CalendarGroupQuery)
      list.value.size.should eq(1)
    end
  end

  describe "#create_calendar" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_calendar

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      calendar = client.create_calendar(mailbox: "foo@bar.com", name: "I Love Calendars")
      calendar.is_a?(Office365::Calendar)
    end
  end

  describe "#create_calendar_group" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_calendar_group

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      calendar = client.create_calendar_group(mailbox: "foo@bar.com", name: "I Love Calendar Groups")
      calendar.should be_a(Office365::CalendarGroup)
    end
  end

  describe "#delete_calendar" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_delete_calendar

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.delete_calendar(mailbox: "foo@bar.com", id: "1234").should eq(true)
    end
  end

  describe "#delete_calendar_group" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_delete_calendar_group

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.delete_calendar_group(mailbox: "foo@bar.com", id: "1234").should eq(true)
    end
  end

  describe "#get_availability" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_availability

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      availability = client.get_availability(mailbox: "foo@bar.com",
        mailboxes: ["foo@bar.com", "foo@baz.com"],
        starts_at: Time.local,
        ends_at: Time.local + 1.hour)

      typeof(availability).should eq(Array(Office365::AvailabilitySchedule))
      availability.first.calendar.should eq("foo@bar.com")
    end
  end
end
