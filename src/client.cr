require "./mail"
require "./users"
require "./groups"
require "./events"
require "./calendars"
require "./attachments"
require "./batch_request"
require "./odata"

module Office365
  USERS_BASE = "/v1.0/users"

  class Client
    include Office365::Mail
    include Office365::Users
    include Office365::Groups
    include Office365::Events
    include Office365::Calendars
    include Office365::Attachments
    include Office365::BatchRequest
    include Office365::OData

    LOGIN_URI     = URI.parse("https://login.microsoftonline.com")
    GRAPH_URI     = URI.parse("https://graph.microsoft.com/")
    DEFAULT_SCOPE = "https://graph.microsoft.com/.default"

    getter token_cache = {} of String => Token

    def initialize(@tenant : String, @client_id : String, @client_secret : String, @scope : String = DEFAULT_SCOPE)
    end

    def get_token : Token
      existing = token_cache[token_lookup]?
      return existing if existing && existing.current?

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
        token_cache[token_lookup] = token
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
      query : Hash(String, String)? = nil,
      headers : HTTP::Headers = default_headers
    ) : HTTP::Request
      if query
        path = "#{path}?#{query.join('&') { |k, v| HTTP::Params.parse("#{k}=#{v}") }}"
      end

      HTTP::Request.new(request_method, path, headers, data)
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
    end

    def default_headers
      HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Content-type"  => "application/json",
        "Prefer"        => %(IdType="ImmutableId"),
      }
    end

    private def access_token
      get_token.access_token
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
