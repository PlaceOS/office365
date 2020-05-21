class Office365::PatternedRecurrence
  include JSON::Serializable

  property pattern : RecurrencePattern?
  property range : RecurrenceRange?

  def initialize(@pattern, @range)
  end

  def self.build(recurrence_start_date : Time, recurrence_end_date : Time, type : RecurrencePatternType)
    pattern = RecurrencePattern.new(type, 1, [Office365::DayOfWeek.parse(recurrence_start_date.to_s("%A"))])
    range = RecurrenceRange.new("endDate", recurrence_start_date.to_s("%F"), recurrence_end_date.to_s("%F"))

    new(pattern, range)
  end
end
