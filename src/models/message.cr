require "./email_address"

module Office365
  class Message
    include JSON::Serializable

    class Body
      include JSON::Serializable

      @[JSON::Field(key: "contentType")]
      property content_type : String
      property content : String

      def initialize(@content : String, @content_type : String = "Text")
        raise "invalid body content type: #{@content_type}" unless {"Text", "HTML"}.includes?(@content_type)
      end
    end

    class Recipient
      include JSON::Serializable

      @[JSON::Field(key: "emailAddress")]
      property address : EmailAddress

      def initialize(address : String, name : String = "")
        @address = EmailAddress.new(address, name)
      end

      def initialize(@address)
      end
    end

    property subject : String
    property body : Body

    @[JSON::Field(key: "toRecipients")]
    property to : Array(Recipient)?

    @[JSON::Field(key: "ccRecipients")]
    property cc : Array(Recipient)?

    @[JSON::Field(key: "bccRecipients")]
    property bcc : Array(Recipient)?

    @[JSON::Field(key: "bodyPreview")]
    property body_preview : String?

    property attachments : Array(Attachment)?

    def initialize(
      @subject,
      content : String,
      content_type : String = "Text",
      to : Array(String) | Array(EmailAddress) | Nil = nil,
      cc : Array(String) | Array(EmailAddress) | Nil = nil,
      bcc : Array(String) | Array(EmailAddress) | Nil = nil,
      @body_preview = nil,
      @attachments = nil
    )
      @body = Body.new(content, content_type)
      @to = to_recipient(to)
      @cc = to_recipient(cc)
      @bcc = to_recipient(bcc)
    end

    protected def to_recipient(emails : Array(String) | Array(EmailAddress) | Nil) : Array(Recipient)?
      return unless emails
      return if emails.empty?
      emails.map { |address| Recipient.new(address) }
    end
  end
end
