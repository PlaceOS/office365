module Office365
  class UserQuery
    include JSON::Serializable

    property value : Array(User)
  end
end
