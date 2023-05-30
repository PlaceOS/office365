module Office365
  # https://docs.microsoft.com/en-us/graph/api/resources/users?view=graph-rest-1.0#common-properties
  class User
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    # Common Properties
    property id : String

    @[JSON::Field(key: "businessPhones")]
    property business_phones : Array(String?)

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "givenName")]
    property given_name : String?

    @[JSON::Field(key: "jobTitle")]
    property job_title : String?

    property mail : String?

    @[JSON::Field(key: "mobilePhone")]
    property mobile_phone : String?

    @[JSON::Field(key: "officeLocation")]
    property office_location : String?

    @[JSON::Field(key: "preferredLanguage")]
    property preferred_language : String?

    property surname : String?

    @[JSON::Field(key: "userPrincipalName")]
    property user_principal_name : String

    # Additional Properties (get through $select query parameter)
    property contacts : Array(Contact)?

    @[JSON::Field(key: "mailNickname")]
    property mail_nickname : String?

    def email
      @mail || @user_principal_name
    end
  end

  struct PasswordProfile
    include JSON::Serializable
    property password : String

    @[JSON::Field(key: "forceChangePasswordNextSignIn")]
    property force_change_password_next_sign_in : Bool

    def initialize(@password, @force_change_password_next_sign_in)
    end
  end

  class UserUpdateRequest
    include JSON::Serializable

    property id : String?

    @[JSON::Field(key: "userPrincipalName")]
    property user_principal_name : String?

    property mail : String?

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "givenName")]
    property given_name : String?

    property surname : String?

    property contacts : Array(Contact)?

    @[JSON::Field(key: "mobilePhone")]
    property mobile_phone : String?

    @[JSON::Field(key: "businessPhones")]
    property business_phones : Array(String?)?

    @[JSON::Field(key: "jobTitle")]
    property job_title : String?

    @[JSON::Field(key: "officeLocation")]
    property office_location : String?

    @[JSON::Field(key: "preferredLanguage")]
    property preferred_language : String?
  end

  class UserCreateRequest < UserUpdateRequest
    include JSON::Serializable

    @[JSON::Field(key: "passwordProfile")]
    property password_profile : PasswordProfile

    @[JSON::Field(key: "accountEnabled")]
    property account_enabled : Bool
  end
end
