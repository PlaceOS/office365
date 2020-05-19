class Office365::AttachmentQuery
  include JSON::Serializable

  property value : Array(Attachment)

  def initialize(@value)
  end
end
