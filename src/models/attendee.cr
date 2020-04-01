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
    property emailAddress : EmailAddress

    delegate name, to: @emailAddress

    def initialize(email : EmailAddress | String, @type = AttendeeType::Required)
      case email
      when String
        @emailAddress = EmailAddress.new(email)
      else
        @emailAddress = email
      end
    end

  end
end
