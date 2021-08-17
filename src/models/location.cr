class Office365::Location
  include JSON::Serializable
  include JSON::Serializable::Unmapped

  property address : PhysicalAddress?

  @[JSON::Field(key: "displayName")]
  property display_name : String?

  @[JSON::Field(key: "locationEmailAddress")]
  property email_address : String?

  @[JSON::Field(key: "locationUri")]
  property uri : String?

  @[JSON::Field(key: "locationType")]
  property type : String? = "default"

  property coordinates : OutlookGeoCoordinates?

  def initialize(@display_name)
  end
end
