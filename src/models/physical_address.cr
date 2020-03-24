class Office365::PhysicalAddress
  include JSON::Serializable

  property city : String
  property countryOrRegion : String
  property postalCode : String
  property state : String
  property street : String
end
