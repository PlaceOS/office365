class Office365::ItemBody
  include JSON::Serializable

  property content : String?

  @[JSON::Field(key: "contentType")]
  property content_type : String?

  def initialize(@content = "", @content_type = "HTML")
  end
end
