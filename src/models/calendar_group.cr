class Office365::CalendarGroup
  include JSON::Serializable

  @[JSON::Field(key: "changeKey")]
  property change_key : String?

  @[JSON::Field(key: "classId")]
  property class_id : String?

  property name : String
  property id : String
end
