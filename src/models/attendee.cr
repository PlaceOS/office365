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
    include JSON::Serializable::Unmapped

    property type : AttendeeType

    @[JSON::Field(key: "emailAddress")]
    property email_address : EmailAddress

    property status : ResponseStatus?

    delegate name, to: @email_address

    def initialize(email : EmailAddress | String, @type = AttendeeType::Required, @status : ResponseStatus? = nil)
      case email
      when String
        @email_address = EmailAddress.new(email)
      else
        @email_address = email
      end
    end
  end
end
