module Office365
  class RequiredResourceAccess
    include JSON::Serializable

    @[JSON::Field(key: "resourceAppId")]
    property resource_app_id : String

    @[JSON::Field(key: "resourceAccess")]
    property resource_access : Array(NamedTuple(id: String, type: String))

    def initialize(@resource_app_id, @resource_access)
    end

    def self.graph_resource_access
      new("00000003-0000-0000-c000-000000000000", Array(NamedTuple(id: String, type: String)).new)
    end

    delegate :<<, to: @resource_access
    delegate :each, to: @resource_access
  end

  class Web
    include JSON::Serializable

    @[JSON::Field(key: "homePageUrl")]
    property homepage_url : String?

    @[JSON::Field(key: "implicitGrantSettings")]
    property implicit_grant_settings : Hash(String, JSON::Any)?

    @[JSON::Field(key: "redirectUris")]
    property redirect_uris : Array(String)?

    @[JSON::Field(key: "logoutUrl")]
    property logout_url : String?

    def initialize(@homepage_url = nil, @implicit_grant_settings = nil, @redirect_uris = nil, @logout_url = nil)
    end

    def add_redirect_uri(url : String)
      @redirect_uris ||= Array(String).new
      redirect_uris.not_nil!.push(url)
    end
  end

  class AppPasswordCredential
    include JSON::Serializable

    @[JSON::Field(key: "customKeyIdentifier")]
    property custom_key_identifier : String?

    @[JSON::Field(key: "endDateTime")]
    property end_date_time : Time?

    @[JSON::Field(key: "keyId")]
    property key_id : String?

    @[JSON::Field(key: "secretText")]
    property secret_text : String?

    @[JSON::Field(key: "startDateTime")]
    property start_date_time : Time?

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    def initialize(@display_name = nil, @start_date_time = nil, @end_date_time = nil)
    end
  end

  class KeyCredential
    include JSON::Serializable

    @[JSON::Field(key: "customKeyIdentifier")]
    property custom_key_identifier : String?

    @[JSON::Field(key: "endDateTime")]
    property end_date_time : String?

    @[JSON::Field(key: "keyId")]
    property key_id : String?

    @[JSON::Field(key: "type")]
    property type : String?

    @[JSON::Field(key: "usage")]
    property usage : String?

    @[JSON::Field(key: "key")]
    property key : String?
  end

  enum SignInAud
    AzureADMyOrg
    AzureADMultipleOrgs
    AzureADandPersonalMicrosoftAccount
    PersonalMicrosoftAccount

    def to_json(json : JSON::Builder)
      json.string(to_s)
    end
  end

  class Application
    include JSON::Serializable

    property id : String?
    @[JSON::Field(key: "appId")]
    property app_id : String?
    @[JSON::Field(key: "displayName")]
    property display_name : String?
    @[JSON::Field(key: "uniqueName")]
    property unique_name : String?
    @[JSON::Field(key: "groupMembershipClaims")]
    property group_membership_claims : String?

    @[JSON::Field(key: "identifierUris")]
    property identifier_uris : Array(String)?
    property api : Hash(String, JSON::Any)?
    @[JSON::Field(key: "appRoles")]
    property app_roles : Array(JSON::Any)?
    @[JSON::Field(key: "signInAudience")]
    property sign_in_audience : SignInAud?
    @[JSON::Field(key: "requiredResourceAccess")]
    property required_resource_access : Array(RequiredResourceAccess)?
    property web : Web?
    property homepage : String?
    property tags : Array(String)?
    property notes : String?
    property info : Hash(String, JSON::Any)?
    @[JSON::Field(key: "isDeviceOnlyAuthSupported")]
    property is_device_only_auth_supported : Bool?
    @[JSON::Field(key: "publisherDomain")]
    property publisher_domain : String?
    @[JSON::Field(key: "verifiedPublisher")]
    property verified_publisher : Hash(String, JSON::Any)?
    property owners : Array(String)?
    @[JSON::Field(key: "createdDateTime")]
    property created_date_time : String?
    @[JSON::Field(key: "optionalClaims")]
    property optional_claims : Hash(String, JSON::Any)?
    @[JSON::Field(key: "keyCredentials")]
    property key_credentials : Array(KeyCredential)?
    @[JSON::Field(key: "passwordCredentials")]
    property password_credentials : Array(AppPasswordCredential)?

    def initialize
    end

    def initialize(@display_name = nil, @sign_in_audience = nil, @web = nil, @required_resource_access = nil)
    end

    def self.single_tenant_app(display_name : String)
      new(display_name, SignInAud::AzureADMyOrg)
    end

    def self.multi_tenant_app(display_name : String)
      new(display_name, SignInAud::AzureADMultipleOrgs)
    end

    def add_required_resource(resource : RequiredResourceAccess)
      @required_resource_access ||= Array(RequiredResourceAccess).new
      required_resource_access.not_nil! << resource
      self
    end

    def add_web_redirect_uri(url : String)
      @web ||= Web.new
      web.not_nil!.add_redirect_uri(url)
      self
    end
  end
end
