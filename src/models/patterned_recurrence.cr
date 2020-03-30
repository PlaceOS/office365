class Office365::PatternedRecurrence
  include JSON::Serializable

  property pattern : RecurrencePattern?
  property range : RecurrenceRange?
end
