module Office365
  class UserQuery
    include JSON::Serializable

    property value : Array(User)
    
    @[JSON::Field(key: "@odata.nextLink")]
    property next_page_token : String?

    def initialize(@value)
    end
  end
end
