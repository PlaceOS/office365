module Office365::OData
  extend self

  # (key1 in ('value1', 'value2', ...))
  def in(key : String, values : Array(_)) : String
    wrap(key, "in", array(values))
  end

  # ('value1', 'value2', ...)
  def array(values : Array(_)) : String
    wrap(values.map { |v| "'#{v}'" }.join(", "))
  end

  # ('value1', 'value2', ...)
  def wrap(*args) : String
    "(" + args.map(&.to_s).join(" ") + ")"
  end
end
