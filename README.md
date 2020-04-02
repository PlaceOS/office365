[![Build Status](https://travis-ci.com/PlaceOS/office365.svg?branch=master)](https://travis-ci.com/PlaceOS/office365)

# office365

Implements the Microsoft Office365 Graph API for the follow

* OAuth Token Generation
  - By providing credentials via argument
* User
  - list Users
  - get User
* Calendar
  - list Calendars
  - list Calendar Groups
  - create Calendar
  - create Calendar Group
  - delete Calendar
  - delete Calendar Group
* Events
  - list Events
  - create Event
  - get Event
  - update Event
  - delete Event


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     google:
       github: PlaceOS/office365
   ```

2. Run `shards install`

## Usage

```crystal
require "office365"
```

### Authentication

#### Office365::Client

```crystal
client = Office365::Client.new(
  tenant: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  client_id: "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  client_secret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
)
```

### Users

```crystal
# id can be either user id, or email
user = client.get_user(id: "foo@bar.com)

# get all users
users = client.list_users

# get top 25 users
users = client.list_users(limit: 25)

# get top 100 users whose email or display name starts with "foo"
users = client.list_users(q: "foo", limit: 100)
```

### Calendars

```crystal
# fetch all foo@bar.com's calendars
calendars = client.list_calendars(mailbox: "foo@bar.com")

# fetch all foo@bar.com's calendar from default calendar group
calendars = client.list_calendars(mailbox: "foo@bar.com", calendar_group_id: "default")

# fetch all foo@bar.com's calendars from a specific calendar group id
calendars = client.list_calendars(mailbox: "foo@bar.com", calendar_group_id: "xxxx-xxxx...")

# fetch foo@bar.com's calendars whose name exactly matches "garys calendar"
calendars = client.list_calendars(mailbox: "foo@bar.com", match: "garys calendar")

# fetch foo@bar.com's calendars whose name starts with "gary"
calendars = client.list_calendars(mailbox: "foo@bar.com", search: "gary")

# fetch all foo@bars calendar groups, limit is optional
groups = client.list_calendar_groups(mailbox: "foo@bar.com", limit: 25)

# create a new calendar, returns an Office365::Calendar objectj
calendar = client.create(
  mailbox: "foo@bar.com",    # required
  name: "My New Calendar",   # required
  calendar_group_id: "..."   # optional
)

# create a calendar group
group = client.create_calendar_group(mailbox: "foo@bar.com", name: "A Whole New Calendar Group!")

# deleting a calendar
client.delete_calendar(
  mailbox: "foo@bar.com",  # required
  id: "...",               # required
  calendar_group_id: "..." # optional
)

# deleting a calendar group
client.delete_calendar_group(
  mailbox: "foo@bar.com",  # required
  id: "...",               # required
)
```

### Events
```crystal
# list events, returns Office365::EventQuery
list = client.list_events(
  mailbox: "foo@bar.com",   # required
  calendar_id: "...",       # optional
  calendar_group_id: "..."  # optional
)

# create an event
event = client.create_event(
  mailbox: "foo@bar.com",
  starts_at: Time.local,
  ends_at: Time.local + 30.minutes,
  calendar_id: "...",
  calendar_group_id: "...",
  subject: "My Meeting",
  description: "A description of my meeting",

  # attendee's can be either a string, EmailAddress, or Attendee
  attendees[
    "string@email.com",
    EmailAddress.new("David Bowie", "david@bowie.net"),
    Attendee.new(
      email: "d.trump@whitehouse.gov",
      type: Office365::AttendeeType::Optional
    )
  ],

  # adds an attendee of type AttendeeType::Resource
  location: "The Red Room",
  sensitivity: Office365::Sensitivity::Normal,

  # adds attendees of type AttendeeType::Resource, string or email address will work
  rooms:[
    "string@email.com",
    EmailAddress.new("David Bowie", "david@bowie.net"),
  ]
)

# get an event
event = client.get_event(mailbox: "foo@bar.com", id: "...")

# update an event
event.description = "Updated: Something new" 
updated_event = client.update_event(event: event, mailbox: "foo@bar.com")

# delete event
client.delete_event(mailbox: "foo@bar.com", id: "...")
```


## Development

To run specs `crystal spec`

## Contributing

1. Fork it (<https://github.com/PlaceOS/google/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
