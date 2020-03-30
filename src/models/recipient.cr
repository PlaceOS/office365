class Office365::Recipient
  include JSON::Serializable

  property emailAddress : EmailAddress?

  def initialize(email : EmailAddress | String)
    case email
    when String
      @emailAddress = EmailAddress.new(email)
    when EmailAddress
      @emailAddress = email
    end
  end
end
