class Office365::EventQuery
  include JSON::Serializable

  property value : Array(Event)

  def initialize(@value)
  end

  def self.from_json(data)
    parsed_data = JSON.parse(data).as_h
    if parsed_data.has_key?("value")
      array_data = parsed_data["value"].as_a
      result = array_data.map do |event|
        Event.from_json(event.to_json)
      end
      new(value: result)
    else
      raise JSON::Error.new "Query not in the correct query format\nOffice365 Error: #{parsed_data["error"]["message"]}"
    end
  end
end
