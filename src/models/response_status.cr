module Office365
  struct ResponseStatus
    include JSON::Serializable
    enum Response
      None
      Organizer
      TentativelyAccepted
      Accepted
      Declined
      NotResponded

      def to_json(json : JSON::Builder)
        json.string(to_s.downcase)
      end
    end

    property response : Response?
    property time : String?

    def initialize(@response, @time)
    end
  end
end
