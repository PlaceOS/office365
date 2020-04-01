class Office365::ItemBody
  include JSON::Serializable

  property content
  property contentType

  def initialize(@content = "", @contentType = "HTML")
  end
end
