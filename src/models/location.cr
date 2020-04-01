class Office365::Location
  include JSON::Serializable

  property address : PhysicalAddress?

  @[JSON::Field(key: "displayName")]
  property display_name : String?

  @[JSON::Field(key: "locationEmailAddress")]
  property location_email_address : String?

  @[JSON::Field(key: "locationUri")]
  property location_uri : String?

  @[JSON::Field(key: "locationType")]
  property location_type : String?

  @[JSON::Field(key: "uniqueIdType")]
  property unique_id_type : String?

  @[JSON::Field(key: "uniqueId")]
  property unique_id : String?

  def initialize(@display_name)
  end
end
