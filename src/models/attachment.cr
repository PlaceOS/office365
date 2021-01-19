module Office365
  module ContentBytesConverter
    def self.from_json(value : JSON::PullParser) : String
      Base64.decode_string(value.read_string)
    end

    def self.to_json(value : String, json : JSON::Builder)
      json.string(value)
    end
  end

  class Attachment
    include JSON::Serializable

    property id : String?
    property name : String

    @[JSON::Field(key: "contentType")]
    property content_type : String?

    @[JSON::Field(key: "contentBytes", converter: Office365::ContentBytesConverter)]
    property content_bytes : String

    @[JSON::Field(key: "@odata.type")]
    property odata_type : String

    @[JSON::Field(key: "contentId")]
    property content_id : String?

    @[JSON::Field(key: "isInline")]
    property is_inline : Bool?

    property size : Int32?

    def initialize(@name, content_bytes : String)
      @odata_type = "#microsoft.graph.fileAttachment"
      @content_bytes = Base64.strict_encode(content_bytes)
    end

    def initialize(@name, content_bytes : IO)
      @odata_type = "#microsoft.graph.fileAttachment"
      buffer = IO::Memory.new
      buf = Bytes.new(64)
      while ((bytes = content_bytes.read(buf)) > 0)
        buffer.write(buf[0, bytes])
      end
      @content_bytes = Base64.strict_encode(buffer)
    end
  end
end
