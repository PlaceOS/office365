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

  describe "list_users" do
    it "#list_users suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_users

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      user_list = client.list_users
      user_list.value.size.should eq(1)
      user_list.value.first.display_name.should eq(SpecHelper.mock_user.display_name)
    end

    it "#list_users with custom query" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_users_with_query

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      query_params = {"$filter" => Office365::OData.in("id", ["1234-5678-9012", "1234-5678-5435"])}

      user_list = client.list_users_by_query(query_params)
      user_list.value.size.should eq(1)
      user_list.value.first.display_name.should eq(SpecHelper.mock_user.display_name)
    end
  end

  describe "create_user" do
    it "#create_user_from_json" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_user

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.create_user_from_json(SpecHelper.mock_create_user_request_body.to_json).display_name.should eq(SpecHelper.mock_create_user_request_body["displayName"])
    end
  end

  describe "update_user" do
    it "#update_user_from_json" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_create_user
      SpecHelper.mock_update_user

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      user = client.create_user_from_json(SpecHelper.mock_create_user_request_body.to_json)
      updated = client.update_user_from_json(user.id, SpecHelper.mock_update_user_request_body.to_json)
      updated.status_code.should eq(204)
    end
  end

  it "#delete_user" do
    SpecHelper.mock_client_auth
    SpecHelper.mock_create_user
    SpecHelper.mock_delete_user

    client = Office365::Client.new(**SpecHelper.mock_credentials)

    user = client.create_user_from_json(SpecHelper.mock_create_user_request_body.to_json)
    result = client.delete_user(user.id)
    result.status_code.should eq(204)
  end
end
