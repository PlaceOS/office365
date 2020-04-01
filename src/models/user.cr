module Office365
  class User
    include JSON::Serializable

    property id : String
    property mobilePhone : String?
    property displayName : String?
    property mail : String?
    property jobTitle : String?

    property contacts : Array(Contact)?

  end
end
