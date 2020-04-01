module Office365
  enum AttendeeType
    Required
    Optional
    Resource

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  class Attendee
    include JSON::Serializable

    property type : AttendeeType

    @[JSON::Field(key: "emailAddress")]
    property email_address : EmailAddress

    delegate name, to: @email_address

    def initialize(email : EmailAddress | String, @type = AttendeeType::Required)
      case email
      when String
        @email_address = EmailAddress.new(email)
      else
        @email_address = email
      end
    end
  end
end
