class Office365::OutlookGeoCoordinates
  include JSON::Serializable

  @[JSON::Field(key: "altitudeAccuracy")]
  property altitude_accuracy : Float64?

  property accuracy : Float64?
  property altitude : Float64?
  property latitude : Float64?
  property longitude : Float64?
end
