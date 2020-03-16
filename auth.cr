require "connect-proxy"
require "./token"

module Office365

  class Auth
    LOGIN_URI    = URI.parse("https://login.microsoftonline.com")
    TOKENS_CACHE = {} of String => Token

    def initialize(@tenant : String, @client_id : String, @client_secret : String, @scope : String = "https://graph.microsoft.com/.default")
    end

    def get_token : Token
      existing = TOKENS_CACHE[token_lookup]?
      return existing if existing && existing.current?

      response = ConnectProxy::HTTPClient.new(LOGIN_URI) do |client|
        client.exec(
          "POST",
          "/#{@tenant}/oauth2/v2.0/token",
          HTTP::Headers {
            "Content-Type" => "application/x-www-form-urlencoded"
          },
          "client_id=#{@client_id}&scope=#{URI.encode(@scope)}&client_secret=#{@client_secret}&grant_type=client_credentials"
        )
      end

      if response.success?
        token = Token.from_json response.body
        TOKENS_CACHE[token_lookup] = token
        token
      else
        raise "error fetching token #{response.status} (#{response.status_code})\n#{response.body}"
      end
    end

    private def token_lookup
      "#{@tenant}_#{@client_id}"
    end
  end
end
