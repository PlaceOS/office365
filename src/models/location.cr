class Office365::Location
  include JSON::Serializable

  property address : PhysicalAddress?
  property displayName : String?
  property locationEmailAddress : String?
  property locationUri : String?
  property locationType : String?
  property uniqueIdType : String?
  property uniqueId : String?

  def initialize(@displayName)
  end
end
