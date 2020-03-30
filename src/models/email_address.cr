class Office365::EmailAddress
  include JSON::Serializable

  property address : String
  property name : String

  def initialize(@address, @name = "")
    @name = @address if @name.blank?
  end
end
