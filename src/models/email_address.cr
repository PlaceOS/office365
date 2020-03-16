require "json"

module Office365
  class EmailAddress
    include JSON::Serializable

    property address : String
    property name : String
  end
end
