module Office365::Events
  def list_events(mailbox : String, calendar_group_id : String? = nil, calendar_id : String? = nil)

    case {calendar_group_id, calendar_id}
    when {Nil, Nil}
      endpoint = "/v1.0/users/#{mailbox}/calendar/events"
    when {Nil, String}
      endpoint = "/v1.0/users/#{mailbox}/calendars/#{calendar_id}/events"
    when {"default", String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroup/calendars/#{calendar_id}/events"
    when {String, String}
      endpoint = "/v1.0/users/#{mailbox}/calendargroups/#{calendar_group_id}/calendars/#{calendar_id}/events"
    end


  end

end
