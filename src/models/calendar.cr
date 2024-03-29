class Office365::Calendar
  include JSON::Serializable
  include JSON::Serializable::Unmapped

  @[JSON::Field(key: "canEdit")]
  property? can_edit : Bool?

  @[JSON::Field(key: "canShare")]
  property? can_share : Bool?

  @[JSON::Field(key: "canViewPrivateItems")]
  property? can_view_private_items : Bool?

  @[JSON::Field(key: "changeKey")]
  property change_key : String?

  @[JSON::Field(key: "isDefaultCalendar")]
  property? is_default_calendar : Bool?

  @[JSON::Field(key: "isRemovable")]
  property? is_removable : Bool?

  property color : String?
  property id : String
  property name : String

  property owner : EmailAddress?
end
