require "./group"

module Office365
  class GroupQuery
    include JSON::Serializable

    property value : Array(Group)

    def initialize(@value)
    end
  end
end
