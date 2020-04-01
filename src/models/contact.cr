module Office365
  class Contact
    include JSON::Serializable

    property id : String
    property title : String

    @[JSON::Field(key: "mobilePhone")]
    property mobile_phone : String

    @[JSON::Field(key: "companyName")]
    property company_name : String

    @[JSON::Field(key: "displayName")]
    property display_name : String

    @[JSON::Field(key: "personalNotes")]
    property personal_notes : String

    @[JSON::Field(key: "emailAddresses")]
    property email_addresses : Array(EmailAddress)
  end
end
