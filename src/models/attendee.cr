class Office365::Attendee
  include JSON::Serializable

  property type : String
  property emailAddress : EmailAddress
end
