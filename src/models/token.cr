require "json"

module Office365
  class Token
    include JSON::Serializable

    property access_token : String
    property token_type : String
    property expires_in : Int32
    property created_at : Time = Time.utc

    def current?
      Time.utc <= expires_at
    end

    def expired?
      Time.utc > expires_at
    end

    def initialize(@access_token, @token_type, @expires_in)
    end

    private def expires_at
      @created_at + @expires_in.seconds
    end
  end
end
