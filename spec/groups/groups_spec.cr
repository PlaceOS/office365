require "../spec_helper"

describe Office365::Groups do
  describe "#get_group" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_group

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.get_group(SpecHelper.mock_group.id).display_name.should eq(SpecHelper.mock_group.display_name)
    end
  end

  describe "#list_group_members" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_group_members

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      user_list = client.list_group_members("1234-5678-9012")
      user_list.value.size.should eq(1)
      user_list.value.first.display_name.should eq(SpecHelper.mock_user.display_name)
    end
  end

  describe "#groups_member_of" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_groups_member_of

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      groups_list = client.groups_member_of(SpecHelper.mock_user.id)
      groups_list.value.size.should eq(1)
      groups_list.value.first.display_name.should eq(SpecHelper.mock_group.display_name)
    end
  end

  describe "#list_groups" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_groups

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      groups_list = client.list_groups("query")
      groups_list.value.size.should eq(1)
      groups_list.value.first.display_name.should eq(SpecHelper.mock_group.display_name)
    end
  end
end
