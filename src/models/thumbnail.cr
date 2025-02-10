module Office365
  class Thumbnail
    include JSON::Serializable

    property height : Int32?
    property width : Int32?
    property content : String?
    property url : String?

    @[JSON::Field(key: "sourceItemId")]
    property source_item_id : String?
  end

  class ThumbnailSet
    include JSON::Serializable

    property id : String?
    property large : Thumbnail?
    property medium : Thumbnail?
    property small : Thumbnail?
    property source : Thumbnail?
  end
end
