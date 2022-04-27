module Office365
  # https://docs.microsoft.com/en-us/graph/api/resources/invitation?view=graph-rest-1.0
  class Invitation
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "invitedUserDisplayName")]
    property display_name : String?

    @[JSON::Field(key: "invitedUserEmailAddress")]
    property email : String

    @[JSON::Field(key: "invitedUserMessageInfo")]
    property message : InvitationMessage?

    @[JSON::Field(key: "sendInvitationMessage")]
    property send_invitation : Bool?

    @[JSON::Field(key: "inviteRedirectUrl")]
    property redirect_url : String

    @[JSON::Field(key: "inviteRedeemUrl")]
    property redeem_url : String?

    @[JSON::Field(key: "invitedUserType")]
    property user_type : String?

    @[JSON::Field(key: "status")]
    property status : String?

    @[JSON::Field(key: "invitedUser")]
    property user : User?

    def initialize(@email : String, @redirect_url : String)
    end
  end
end
