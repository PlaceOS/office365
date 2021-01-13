module Office365
  class User
    include JSON::Serializable

    property id : String
    property mail : String?
    property contacts : Array(Contact)?

    @[JSON::Field(key: "mobilePhone")]
    property mobile_phone : String?

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "userPrincipalName")]
    property user_principal_name : String

    @[JSON::Field(key: "jobTitle")]
    property job_title : String?

    def email
      @mail || @user_principal_name
    end
  end
end
