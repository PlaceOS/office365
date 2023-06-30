require "./recurrence_pattern"

module Office365
  class RecurrenceParam
    property pattern : String
    property range_end : Time
    property interval : Int32?
    property index : WeekIndex?
    property days_of_week : Array(String)
    property first_day_of_week : Office365::DayOfWeek?

    def initialize(@pattern : String, @range_end : Time, @interval : Int32? = 1, @days_of_week : Array(String) = [] of String, first_day_of_week : String? = nil, @index : WeekIndex? = nil)
      @first_day_of_week = first_day_of_week ? Office365::DayOfWeek.parse(first_day_of_week) : Office365::DayOfWeek::Sunday
    end
  end
end
