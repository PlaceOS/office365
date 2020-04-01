class Office365::ItemBody
  include JSON::Serializable

  property content

  @[JSON::Field(key: "contentType")]
  property content_type

  def initialize(@content = "", @content_type = "HTML")
  end
end
