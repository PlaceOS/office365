require "../spec_helper"

describe Office365::Places do
  describe "list_messages" do
    it "list_messages should return the list of messages in channel" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_channel_msgs

      team_id = "fbe2bf47-16c8-47cf-b4a5-4b9b187c508b"
      channel_id = "19:4a95f7d8db4c4e7fae857bcebe0623e6@thread.tacv2"

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      messages = client.list_channel_messages(team_id: team_id, channel_id: channel_id, top: 3)
      messages.count.should eq(3)
      messages.next_link.should_not be_nil
      messages.value.size.should eq(3)
    end

    it "should get message in channel" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_channel_msg

      team_id = "fbe2bf47-16c8-47cf-b4a5-4b9b187c508b"
      channel_id = "19:4a95f7d8db4c4e7fae857bcebe0623e6@thread.tacv2"
      msg_id = "1614618259349"
      client = Office365::Client.new(**SpecHelper.mock_credentials)

      message = client.get_channel_message(team_id: team_id, channel_id: channel_id, message_id: msg_id)
      message.id.should eq("1612289992105")
    end

    it "should send message in channel" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_channel_send_msg

      team_id = "fbe2bf47-16c8-47cf-b4a5-4b9b187c508b"
      channel_id = "19:4a95f7d8db4c4e7fae857bcebe0623e6@thread.tacv2"
      client = Office365::Client.new(**SpecHelper.mock_credentials)

      resp = client.send_channel_message(team_id, channel_id, "Hello World")
      resp.status_code.should eq(201)
    end
  end
end
