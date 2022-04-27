module Office365
  # https://docs.microsoft.com/en-us/graph/api/resources/invitedusermessageinfo?view=graph-rest-1.0
  class InvitationMessage
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "ccRecipients")]
    property cc_recipients : Array(EmailAddress)?

    @[JSON::Field(key: "customizedMessageBody")]
    property body : String?

    @[JSON::Field(key: "messageLanguage")]
    property language : String?
  end
end
