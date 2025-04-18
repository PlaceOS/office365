require "../spec_helper"

describe Office365::Application do
  it "List applications" do
    SpecHelper.mock_client_auth
    SpecHelper.mock_list_applications

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    list = client.list_applications
    list.size.should eq(1)
  end

  it "creates application" do
    SpecHelper.mock_client_auth
    SpecHelper.mock_create_applications

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    app = Office365::Application.new(display_name: "Display Name")
    created_app = client.create_application(app)
    created_app.should_not be_nil
    created_app.sign_in_audience.should eq(Office365::SignInAud::AzureADandPersonalMicrosoftAccount)
  end

  it "add password to existing application" do
    SpecHelper.mock_client_auth
    SpecHelper.mock_applications_add_pwd

    client = Office365::Client.new(**SpecHelper.mock_credentials)
    pwd = client.application_add_pwd("my-app", "Password friendly name")
    pwd.should_not be_nil
    pwd.display_name.should eq("Password friendly name")
  end

  it "get partial application contents" do
    SpecHelper.mock_client_auth
    SpecHelper.mock_get_application_id_and_web
    client = Office365::Client.new(**SpecHelper.mock_credentials)
    app = client.get_application("my-app", "id,web")
    app.web.should_not be_nil,
      app.web.not_nil!.redirect_uris.try &.size.should eq(2)
  end
end
