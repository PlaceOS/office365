module Office365
  class ChatMessageAttachment
    include JSON::Serializable

    property id : String
    property name : String?
    property content : String?

    @[JSON::Field(key: "contentType")]
    property content_type : String?

    @[JSON::Field(key: "contentUrl")]
    property content_url : String?

    @[JSON::Field(key: "teamsAppId")]
    property teams_app_id : String?

    @[JSON::Field(key: "thumbnailUrl")]
    property thumbnail_url : String?
  end
end
