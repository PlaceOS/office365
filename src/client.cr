require "./mail"
require "./users"
require "./groups"
require "./events"
require "./calendars"
require "./attachments"
require "./batch_request"
require "./subscriptions"
require "./odata"
require "./password_credentials"

module Office365
  USERS_BASE       = "/v1.0/users"
  INVITATIONS_BASE = "/v1.0/invitations"

  class Client
    include Office365::Mail
    include Office365::Users
    include Office365::Groups
    include Office365::Events
    include Office365::Calendars
    include Office365::Attachments
    include Office365::BatchRequest
    include Office365::Subscriptions
    include Office365::OData
    include Office365::PasswordCredentials

    LOGIN_URI     = URI.parse("https://login.microsoftonline.com")
    GRAPH_URI     = URI.parse("https://graph.microsoft.com/")
    DEFAULT_SCOPE = "https://graph.microsoft.com/.default"

    class_getter token_cache = {} of String => Token
    @token : String? = nil

    def initialize(@tenant : String, @client_id : String, @client_secret : String, @scope : String = DEFAULT_SCOPE)
    end

    def initialize(token : String)
      @token = token
      @tenant = @client_id = @client_secret = @scope = ""
    end

    def get_token : Token
      if static = @token
        return Token.new(static, "", 5.hours.total_seconds.to_i)
      end

      existing = self.class.token_cache[token_lookup]?
      if existing
        if !existing.current?
          self.class.token_cache.delete(token_lookup)
        else
          return existing
        end
      end

      response = ConnectProxy::HTTPClient.new(LOGIN_URI) do |client|
        params = HTTP::Params{
          "client_id"     => @client_id,
          "scope"         => @scope,
          "client_secret" => @client_secret,
          "grant_type"    => "client_credentials",
        }

        params["code"] = get_delegated_code unless @scope == DEFAULT_SCOPE

        client.exec(
          "POST",
          "/#{@tenant}/oauth2/v2.0/token",
          HTTP::Headers{
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          params.to_s
        )
      end

      if response.success?
        token = Token.from_json response.body
        self.class.token_cache[token_lookup] = token
        token
      else
        raise "error fetching token #{response.status} (#{response.status_code})\n#{response.body}"
      end
    end

    # https://docs.microsoft.com/en-us/graph/auth-v2-user
    private def get_delegated_code
      response = ConnectProxy::HTTPClient.new(LOGIN_URI) do |client|
        params = HTTP::Params{
          "client_id"     => @client_id,
          "response_type" => "code",
          "scope"         => @scope,
        }
        client.exec(
          "POST",
          "/#{@tenant}/oauth2/v2.0/token",
          HTTP::Headers{
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          params.to_s
        )
      end
      raise "error fetching authorisation code #{response.status} (#{response.status_code})\n#{response.body}" unless response.success?

      authorisation_response = Hash(String, String).from_json response.body
      authorisation_response["code"]
    end

    def graph_http_request(
      request_method : String,
      path : String,
      data : String? = nil,
      query : URI::Params? = nil,
      headers : HTTP::Headers = default_headers
    ) : HTTP::Request
      uri = if query && !query.empty?
              "#{URI.encode_path(URI.decode(path))}?#{query}"
            else
              # Decode all of the encoded values that might've been accidentally or purposely encoded.
              URI.encode_path(URI.decode(path))
            end

      HTTP::Request.new(request_method, uri, headers, data)
    end

    def graph_request(http_request : HTTP::Request)
      response = ConnectProxy::HTTPClient.new(GRAPH_URI) do |client|
        client.exec(http_request)
      end

      if response.success?
        response
      else
        raise Office365::Exception.new(response.status, response.body, response.status.description)
      end
    rescue error : ArgumentError
      # TODO:: remove once merged https://github.com/crystal-lang/crystal/issues/13134
      raise error unless error.message.try(&.includes?("should not have a body"))
      HTTP::Client::Response.new(:no_content)
    end

    def default_headers
      HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Content-Type"  => "application/json",
        "Prefer"        => %(IdType="ImmutableId"),
      }
    end

    private def access_token : String
      @token || get_token.access_token
    end

    private def token_lookup
      "#{@tenant}_#{@client_id}"
    end
  end

  class Exception < ::RuntimeError
    property http_status : HTTP::Status
    property http_body : String

    def initialize(@http_status, @http_body, @message = nil)
    end
  end
end
