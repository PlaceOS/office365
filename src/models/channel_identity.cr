module Office365
  class ChannelIdentity
    include JSON::Serializable

    @[JSON::Field(key: "channelId")]
    property channel_id : String

    @[JSON::Field(key: "teamId")]
    property team_id : String
  end
end
