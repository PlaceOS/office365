module Office365
  enum ChatMessageType
    Message
    ChatEvent
    Typing
    UnknownFutureValue
    SystemEventMessage

    def to_json(json : JSON::Builder)
      val = to_s
      val = val[0].downcase + val[1..]
      json.string(val)
    end
  end

  enum ChatMessageActions
    ReactionAdded
    ReactionRemoved
    ActionUndefined
    UnknownFutureValue

    def to_json(json : JSON::Builder)
      val = to_s
      val = val[0].downcase + val[1..]
      json.string(val)
    end
  end

  enum ChatMessagePolicyViolationDlpActionType
    None
    NotifySender
    BlockAccess
    BlockAccessExternal
  end

  class ChatMessageMention
    include JSON::Serializable

    property id : Int32?
    property mentioned : ChatMessageMentionedIdentitySet?

    @[JSON::Field(key: "mentionText")]
    property mention_text : String?
  end

  class ChatMessageReaction
    include JSON::Serializable

    @[JSON::Field(key: "createdDateTime")]
    property created_date_time : String?

    @[JSON::Field(key: "displayName")]
    property display_name : String?

    @[JSON::Field(key: "reactionContentUrl")]
    property reaction_content_url : String?

    @[JSON::Field(key: "reactionType")]
    property reaction_type : String?

    property user : ChatMessageReactionIdentitySet?
  end

  class ChatMessageHistoryItem
    include JSON::Serializable

    property actions : ChatMessageActions

    @[JSON::Field(key: "modifiedDateTime")]
    property modified_date_time : Time?

    property reaction : ChatMessageReaction?
  end

  class ChatMessagePolicyTip
    include JSON::Serializable

    @[JSON::Field(key: "complianceUrl")]
    property compliance_url : String?

    @[JSON::Field(key: "generalText")]
    property general_text : String?

    @[JSON::Field(key: "matchedConditionDescriptions")]
    property matched_condition_descriptions : Array(String)?
  end

  class ChatMessagePolicyViolation
    include JSON::Serializable

    @[JSON::Field(key: "dlpAction")]
    property dlp_action : ChatMessagePolicyViolationDlpActionType?

    @[JSON::Field(key: "justificationText")]
    property justification_text : String?

    @[JSON::Field(key: "policyTip")]
    property policy_tip : ChatMessagePolicyTip?

    @[JSON::Field(key: "userAction")]
    property user_action : ChatMessagePolicyViolationDlpActionType?

    @[JSON::Field(key: "verdictDetails")]
    property verdict_details : ChatMessagePolicyViolationDlpActionType?
  end

  class ChatMessage
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    property attachments : Array(ChatMessageAttachment)?
    property body : ItemBody

    @[JSON::Field(key: "chatId")]
    property chat_id : String?

    @[JSON::Field(key: "channelIdentity")]
    property channel_identity : ChannelIdentity?

    @[JSON::Field(key: "createdDateTime")]
    property created_date_time : Time?

    @[JSON::Field(key: "deletedDateTime")]
    property deleted_date_time : Time?

    property etag : String?

    # @[JSON::Field(key: "eventDetail")]
    # property event_detail : EventMessageDetail?

    property from : ChatMessageFromIdentitySet?
    property id : String?
    property importance : String?

    @[JSON::Field(key: "lastModifiedDateTime")]
    property last_modified_date_time : Time?

    @[JSON::Field(key: "lastEditedDateTime")]
    property last_edited_date_time : Time?

    property locale : String?
    property mentions : Array(ChatMessageMention)?

    @[JSON::Field(key: "messageHistory")]
    property message_history : Array(ChatMessageHistoryItem)?

    @[JSON::Field(key: "messageType")]
    property message_type : ChatMessageType?

    @[JSON::Field(key: "policyViolation")]
    property policy_violation : ChatMessagePolicyViolation?

    property reactions : Array(ChatMessageReaction)?

    @[JSON::Field(key: "replyToId")]
    property reply_to_id : String?

    property subject : String?
    property summary : String?

    @[JSON::Field(key: "webUrl")]
    property web_url : String?

    def initialize(@body, @attachments = nil, @chat_id = nil, @channel_identity = nil, @created_date_time = nil, @deleted_date_time = nil, @etag = nil, @from = nil, @id = nil, @importance = nil, @last_modified_date_time = nil,
                   @last_edited_date_time = nil, @locale = nil, @mentions = nil, @message_history = nil, @message_type = nil, @policy_violation = nil, @reactions = nil, @subject = nil, @summary = nil, @web_url = nil)
    end

    def self.new(content : String, content_type : String)
      new(body: ItemBody.new(content: content, content_type: content_type))
    end

    def self.new(body : String)
      new(content: body, content_type: "TEXT")
    end
  end

  class ChatMessageList
    include JSON::Serializable

    @[JSON::Field(key: "@odata.context")]
    property context : String

    @[JSON::Field(key: "@odata.count")]
    property count : Int32

    @[JSON::Field(key: "@odata.nextLink")]
    property next_link : String?

    property value : Array(ChatMessage)
  end
end
