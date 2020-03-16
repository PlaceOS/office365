require "json"
require "./email_address"

module Office365
  class Contact
    include JSON::Serializable

    property id : String
    property title : String
    property mobilePhone : String
    property companyName : String
    property displayName : String
    property personalNotes : String
    property emailAddresses : Array(EmailAddress)

  end
end
