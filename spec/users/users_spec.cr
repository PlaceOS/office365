require "../spec_helper"

describe Office365::Users do
  describe "#get_user" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_user

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.get_user(SpecHelper.mock_user.id).display_name.should eq(SpecHelper.mock_user.display_name)
    end
  end

  describe "#list_users" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_users

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      user_list = client.list_users
      user_list.value.size.should eq(1)
      user_list.value.first.display_name.should eq(SpecHelper.mock_user.display_name)
    end
  end
end

