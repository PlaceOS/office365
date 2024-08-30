module Office365
  enum PlaceType
    Room
    RoomList

    def to_s(io : IO) : Nil
      name = case self
             when .room?      then "room"
             when .room_list? then "roomList"
             else
               raise "Invalid PlaceType #{self}"
             end
      io << name
    end
  end

  class Place
    include JSON::Serializable

    property address : PhysicalAddress?

    @[JSON::Field(key: "displayName")]
    property display_name : String

    @[JSON::Field(key: "geoCoordinates")]
    property coordinates : OutlookGeoCoordinates?

    property id : String
    property phone : String?
  end

  class RoomList < Place
    include JSON::Serializable

    @[JSON::Field(key: "emailAddress")]
    property email_address : String
  end

  enum RoomBookingType
    Reserved
    Standard

    def to_json(json : JSON::Builder)
      json.string(to_s.downcase)
    end
  end

  class Room < Place
    include JSON::Serializable

    @[JSON::Field(key: "audioDeviceName")]
    property audio_device_name : String?

    @[JSON::Field(key: "bookingType")]
    property booking_type : RoomBookingType?

    property building : String?
    property capacity : Int32?

    @[JSON::Field(key: "displayDeviceName")]
    property display_device_name : String?

    @[JSON::Field(key: "emailAddress")]
    property email_address : String?

    @[JSON::Field(key: "floorLabel")]
    property floor_label : String?

    @[JSON::Field(key: "floorNumber")]
    property floor_number : Int32?

    @[JSON::Field(key: "isWheelChairAccessible")]
    property is_wheel_chair_accessible : Bool?

    property label : String?
    property nickname : String?
    property tags : Array(String)?

    @[JSON::Field(key: "videoDeviceName")]
    property video_device_name : String?
  end

  abstract class PlaceList
    include JSON::Serializable

    @[JSON::Field(key: "@odata.context")]
    property context : String

    use_json_discriminator "@odata.context", {
      "https://graph.microsoft.com/v1.0/$metadata#places/microsoft.graph.room"     => Rooms,
      "https://graph.microsoft.com/v1.0/$metadata#places/microsoft.graph.roomList" => RoomLists,
    }
  end

  class Rooms < PlaceList
    include JSON::Serializable
    property value : Array(Room)
  end

  class RoomLists < PlaceList
    include JSON::Serializable
    property value : Array(RoomList)
  end
end
