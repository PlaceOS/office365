module Office365
  class CalendarPermission
    include JSON::Serializable

    property id : String
    property role : String

    @[JSON::Field(key: "isRemovable")]
    property is_removable : Bool

    @[JSON::Field(key: "isInsideOrganization")]
    property is_inside_organization : Bool

    @[JSON::Field(key: "allowedRoles")]
    property allowed_roles : Array(String)

    @[JSON::Field(key: "emailAddress")]
    property email_address : EmailAddress

    def can_edit?
      role.in?("write", "delegateWithoutPrivateEventAccess", "delegateWithPrivateEventAccess")
    end
  end

  class CalendarPermissionQuery
    include JSON::Serializable

    @[JSON::Field(key: "@odata.context")]
    property context : String?

    property value : Array(CalendarPermission)

    @[JSON::Field(key: "@odata.nextLink")]
    property next_link : String?
  end
end
