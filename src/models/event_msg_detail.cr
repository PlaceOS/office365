module Office365
  abstract class EventMessageDetail
    include JSON::Serializable

    @[JSON::Field(key: "@odata.type")]
    property type : String

    use_json_discriminator "@odata.type", {
      "#microsoft.graph.callEndedEventMessageDetail"    => CallEndedEvent,
      "#microsoft.graph.channelAddedEventMessageDetail" => ChannelAddedEvent,
    }
  end

  class CallEndedEvent < EventMessageDetail
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "callDuration")]
    property call_duration : String?

    @[JSON::Field(key: "callEventType")]
    property call_event_type : String?

    @[JSON::Field(key: "callId")]
    property call_id : String?
  end

  class ChannelAddedEvent < EventMessageDetail
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "channelDisplayName")]
    property channel_display_name : String?

    @[JSON::Field(key: "channelId")]
    property channel_id : String?
  end
end
