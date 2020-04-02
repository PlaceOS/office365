require "../spec_helper"

describe Office365::Client do
  describe "#get_token" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.get_token.access_token.should eq(SpecHelper.mock_token.access_token)
    end
  end
end
