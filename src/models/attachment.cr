module Office365
  class Attachment
    include JSON::Serializable

    property id : String?
    property name : String

    @[JSON::Field(key: "contentType")]
    property content_type : String?

    @[JSON::Field(key: "contentBytes")]
    property content_bytes : String

    @[JSON::Field(key: "@odata.type")]
    property odata_type : String

    @[JSON::Field(key: "contentId")]
    property content_id : String?

    @[JSON::Field(key: "isInline")]
    property is_inline : Bool?

    property size : Int32?

    def initialize(@name, @content_bytes)
      @odata_type = "#microsoft.graph.fileAttachment"
    end
  end
end
