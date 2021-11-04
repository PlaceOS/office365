require "../spec_helper"

describe Office365::Client do
  describe "#get_token" do
    it "creates a default client" do
      SpecHelper.mock_client_auth
      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.get_token.access_token.should eq(SpecHelper.mock_token.access_token)
    end

    it "creates a client with delegated access" do
      SpecHelper.mock_delegated_client_auth
      mock_credentials = SpecHelper.mock_credentials.merge({scope: "user.read mail.read"})
      client = Office365::Client.new(**mock_credentials)
      client.get_token.access_token.should eq(SpecHelper.mock_token.access_token)
    end
  end
end
