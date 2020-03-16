require "connect-proxy"
require "../auth/auth"

module Office365
  class Calendars

    def initialize(@auth : Office365::Auth)
    end

    def list
      response = ConnectProxy::HTTPClient.new(GRAPH_API) do |client|
        
      end
    end

  end
end

