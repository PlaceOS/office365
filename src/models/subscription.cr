module Office365
  class Subscription
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[Flags]
    enum Change
      Created
      Updated
      Deleted
    end

    def initialize(@resource, change_types : Change, @notification_url, expiration_date_time, @client_state, @lifecycle_notification_url)
      types = Array(String).new(3)
      change_types.each { |member, _value| types << member.to_s.downcase }
      @change_types = types.join(",")
      @expiration_date_time = expiration_date_time.to_utc
    end

    property id : String? = nil
    property resource : String

    @[JSON::Field(key: "changeType")]
    property change_types : String

    @[JSON::Field(key: "notificationUrl")]
    property notification_url : String

    @[JSON::Field(key: "expirationDateTime")]
    property expiration_date_time : Time

    @[JSON::Field(key: "clientState")]
    property client_state : String?

    @[JSON::Field(key: "lifecycleNotificationUrl")]
    property lifecycle_notification_url : String?

    struct Lifecycle
      include JSON::Serializable
      include JSON::Serializable::Unmapped

      enum Event
        ReauthorizationRequired
        SubscriptionRemoved
        Missed
      end

      @[JSON::Field(key: "lifecycleEvent")]
      getter lifecycle_event : Event

      @[JSON::Field(key: "subscriptionId")]
      getter subscription_id : String

      @[JSON::Field(key: "clientState")]
      getter client_state : String?
    end

    struct Notification
      include JSON::Serializable
      include JSON::Serializable::Unmapped

      enum Event
        Created
        Updated
        Deleted
      end

      @[JSON::Field(key: "changeType")]
      getter change : Event

      @[JSON::Field(key: "subscriptionId")]
      getter subscription_id : String
      getter resource : String

      @[JSON::Field(key: "clientState")]
      getter client_state : String?

      @[JSON::Field(key: "subscriptionExpirationDateTime")]
      getter expiration_date_time : Time?
    end
  end
end
