require "./spec_helper"

describe Office365::Users do
  describe "#send_mail" do
    it "suceeds when everything goes well" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_mail

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      client.send_mail(SpecHelper.mock_user.id, Office365::Message.new("subject", "body")).should eq(true)
    end
  end
end
