module Office365
  class UserQuery
    include JSON::Serializable

    property value : Array(User)

    def initialize(@value)
    end
  end
end
