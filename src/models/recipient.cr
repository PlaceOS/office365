class Office365::Recipient
  include JSON::Serializable

  @[JSON::Field(key: "emailAddress")]
  property email_address : EmailAddress?

  def initialize(email : EmailAddress | String)
    case email
    when String
      @email_address = EmailAddress.new(email)
    when EmailAddress
      @email_address = email
    end
  end
end
