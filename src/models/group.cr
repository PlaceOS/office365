module Office365
  class Group
    include JSON::Serializable

    property id : String
    property description : String?
    property visibility : String?
    property mail : String?

    @[JSON::Field(key: "mailEnabled")]
    property mail_enabled : Bool

    @[JSON::Field(key: "displayName")]
    property display_name : String

    @[JSON::Field(key: "membershipRule")]
    property membership_rule : String?
  end
end
