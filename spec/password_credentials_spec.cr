require "./spec_helper"

describe Office365::PasswordCredentials do
  describe "#secret_expiry" do
    it "should return secret expiry when present" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_application

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      expiry = client.secret_expiry
      expiry.should_not be_nil
      expiry.should eq(Time::Format::ISO_8601_DATE_TIME.parse("2025-03-12T23:44:20.176Z"))
    end

    it "should return nil when expiry data is not present" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_application(false)

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      expiry = client.secret_expiry
      expiry.should be_nil
    end
  end
end
