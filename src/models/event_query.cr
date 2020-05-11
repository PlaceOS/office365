class Office365::EventQuery
  include JSON::Serializable

  property value : Array(Event)

  def initialize(@value)
  end

  def self.from_json(data)
    parsed_data = JSON.parse(data).as_h["value"].as_a
    result = parsed_data.map do |event|
      Event.from_json(event.to_json)
    end
    new(value: result)
  end
end
