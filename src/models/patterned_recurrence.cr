class Office365::PatternedRecurrence
  include JSON::Serializable

  property pattern : RecurrencePattern?
  property range : RecurrenceRange?

  def initialize(@pattern, @range)
  end

  def self.build(recurrence_start_date : Time, recurrence : RecurrenceParam)
    days_of_week = recurrence.days_of_week ? [Office365::DayOfWeek.parse(recurrence.days_of_week.not_nil!)] : [Office365::DayOfWeek.parse(recurrence_start_date.to_s("%A"))]
    pattern = case recurrence.pattern
              when "daily"
                RecurrencePattern.new(Office365::RecurrencePatternType::Daily, recurrence.interval)
              when "weekly"
                RecurrencePattern.new(Office365::RecurrencePatternType::Weekly, recurrence.interval, days_of_week, recurrence.first_day_of_week)
              when "monthly"
                RecurrencePattern.new(Office365::RecurrencePatternType::RelativeMonthly, recurrence.interval, days_of_week)
              end
    range = RecurrenceRange.new("endDate", recurrence_start_date.to_s("%F"), recurrence.range_end.to_s("%F"))

    new(pattern, range)
  end
end
