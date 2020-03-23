class Office365::Calendar
  include JSON::Serializable

  property canEdit : Bool?
  property canShare : Bool?
  property canViewPrivateItems : Bool?
  property changeKey : String?
  property color : String?
  property id : String
  property name : String

  property owner : EmailAddress?
end
