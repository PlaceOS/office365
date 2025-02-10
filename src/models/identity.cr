module Office365
  class Identity
    include JSON::Serializable

    property id : String

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "tenantId")]
    property tenant_id : String?

    property thumbnails : ThumbnailSet?
  end

  class TeamworkUserIdentity
    include JSON::Serializable

    property id : String

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "tenantId")]
    property tenant_id : String?

    @[JSON::Field(key: "userIdentityType")]
    property user_identity_type : String?
  end

  class ChatMessageFromIdentitySet
    include JSON::Serializable

    property application : Identity?
    property device : Identity?
    property user : TeamworkUserIdentity?
  end

  class TeamworkConversationIdentity
    include JSON::Serializable

    property id : String

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "conversationIdentityType")]
    property conversation_identity_type : String?
  end

  class ChatMessageMentionedIdentitySet
    include JSON::Serializable

    property application : Identity?
    property conversation : TeamworkConversationIdentity?
    property device : Identity?
    property user : Identity?
  end

  class ChatMessageReactionIdentitySet
    include JSON::Serializable

    property application : Identity?
    property device : Identity?
    property user : Identity?
  end
end
