require "../spec_helper"

describe Office365::Places do
  describe "list_places" do
    it "list_places works for rooms" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_room

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      rooms = client.list_rooms

      rooms.value.size.should eq(2)
      rooms.value.first.is_a?(Office365::Room).should be_true

      list = client.list_places

      list.value.size.should eq(2)
      list.value.first.is_a?(Office365::Room).should be_true
    end

    it "list_places works for roomList" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_list_room_list

      client = Office365::Client.new(**SpecHelper.mock_credentials)

      room_list = client.list_room_list

      room_list.value.size.should eq(2)
      room_list.value.first.is_a?(Office365::RoomList).should be_true

      list = client.list_places(type: Office365::PlaceType::RoomList)

      list.value.size.should eq(2)
      list.value.first.is_a?(Office365::RoomList).should be_true
    end
  end

  describe "#get_place" do
    it "get room when room id is provided" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_room

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      id = "979e9793-3e91-40eb-b18c-0ea937893956"

      room = client.get_room(id)
      room.is_a?(Office365::Room).should be_true
      room.id.should eq(id)
    end

    it "get RoomList when room list email provided" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_room_list

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      email = "Building2Rooms@contoso.com"

      room = client.get_room_list(email)
      room.is_a?(Office365::RoomList).should be_true
      room.email_address.should eq(email)
    end
  end

  describe "#list_room_in_room_list" do
    it "list rooms in room list" do
      SpecHelper.mock_client_auth
      SpecHelper.mock_get_room_in_room_list

      client = Office365::Client.new(**SpecHelper.mock_credentials)
      email = "Building2Rooms@contoso.com"

      rooms = client.list_rooms_in_room_list(email)
      rooms.is_a?(Office365::RoomLists).should be_true
      rooms.value.size.should eq(3)
      rooms.value.first.is_a?(Office365::RoomList).should be_true
    end
  end
end
