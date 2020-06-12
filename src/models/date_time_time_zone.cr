module Office365::DateTimeTimeZone
  extend self

  def to_json(value, json : JSON::Builder)
    json.object do
      json.field("dateTime", value.to_s("%FT%R"))
      json.field("timeZone", extract_tz(value))
    end
  end

  def from_json(pull : JSON::PullParser)
    value = nil
    timezone = nil

    pull.read_object do |key, _|
      case key
      when "dateTime"
        value = pull.read_string
      when "timeZone"
        timezone = pull.read_string
      else
        # do nothing
      end
    end

    if !timezone.nil? && !value.nil?
      Time.parse(value, "%FT%R", tz_location(timezone))
    else
      raise "Couldn't parse DateTimeTimeZone"
    end
  end

  def extract_tz(value : Time)
    tz = value.location.to_s
    case tz
    when "Local"
      "UTC"
    else
      tz
    end
  end

  def tz_location(tz : String)
    loc = WindowsToTzdata.translate(tz)

    loc ? Time::Location.load(loc) : Time::Location.load(tz)
  end
end
