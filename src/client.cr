require "./users"
require "./calendars"
require "./events"

module Office365
  class Client
    include Office365::Users
    include Office365::Calendars
    include Office365::Events

    LOGIN_URI    = URI.parse("https://login.microsoftonline.com")
    GRAPH_URI    = URI.parse("https://graph.microsoft.com/")
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
          HTTP::Headers{
            "Content-Type" => "application/x-www-form-urlencoded",
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

    private def graph_request(
      request_method : String,
      path : String,
      data : String? = nil,
      query : Hash(String, String)? = nil,
      headers : HTTP::Headers = default_headers
    )
      if query
        path = "#{path}?#{query.map { |k, v| HTTP::Params.parse("#{k}=#{v}") }.join("&")}"
      end

      ConnectProxy::HTTPClient.new(GRAPH_URI) do |client|
        client.exec(
          method: request_method,
          path: path,
          headers: headers,
          body: data
        )
      end
    end

    private def default_headers
      HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Content-type"  => "application/json",
      }
    end

    private def access_token
      get_token.access_token
    end

    private def token_lookup
      "#{@tenant}_#{@client_id}"
    end
  end
end
