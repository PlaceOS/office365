class Office365::PhysicalAddress
  include JSON::Serializable

  property city : String?
  property state : String?
  property street : String?

  @[JSON::Field(key: "countryOrRegion")]
  property country_or_region : String?

  @[JSON::Field(key: "postalCode")]
  property postal_code : String?
end
