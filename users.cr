require "connect-proxy"
require "../auth/auth"
require "./user_query"

module Office365
  class Users
    GRAPH_URI = URI.parse("https://graph.microsoft.com/")


    def initialize(@auth : Office365::Auth)
    end

    def list
      response = ConnectProxy::HTTPClient.new(GRAPH_URI) do |client|
        client.exec(
          "GET",
          "/v1.0/users",
          HTTP::Headers {
            "Authorization" => "Bearer #{get_token}"
          }
        )
      end

      if response.success?
        UserQuery.from_json response.body
      else
        raise "error fetching users list #{response.status} (#{response.status_code}\n#{response.body}"
      end
    end

    private def get_token
      @auth.get_token.access_token
    end
  end
end
