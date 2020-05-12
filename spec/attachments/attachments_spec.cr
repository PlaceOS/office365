require "../spec_helper"

describe Office365::Attachments do
  describe "#list_attachments" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_attachments

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      list = client.list_attachments(mailbox: "foo@bar.com", event_id: "1234")
      list.value.size.should eq(1)
      list.value.first.name.should eq(SpecHelper.mock_attachment.name)
    end
  end

  describe "#create_attachment" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_attachment

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      attachment = client.create_attachment(mailbox: "foo@bar.com",
        event_id: "1234",
        name: "test.txt",
        content_bytes: "SGVsbG8gd29ybGQ=")
      attachment.name.should eq(SpecHelper.mock_attachment.name)
    end
  end

  describe "#get_attachment" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_attachment

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      attachment = client.get_attachment(id: "1234", event_id: "1234", mailbox: "foo@bar.com")
      attachment.name.should eq(SpecHelper.mock_attachment.name)
    end
  end

  describe "#delete_attachment" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_delete_attachment

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.delete_attachment(id: "1234", event_id: "1234", mailbox: "foo@bar.com").should eq(true)
    end
  end
end
