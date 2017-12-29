#
# Create some users
#

User.create!(
  first_name: "Shakuntala",
  last_name: "Devi",
  email: "Shakuntala.Devi@example.com",
  role: "read_write"
)

User.create!(
  first_name: "Srinivasa",
  last_name: "Ramanujan",
  email: "Srinivasa.Ramanujan@example.com",
  role: "read"
)

#
# Create the Clockwork Events
#

Clockface::ClockworkEvent.create(
  name: "Example Event 1",
  description: "Runs the Example Event 1",
  command: "{\"class\":\"ExampleWorkerOne\"}"
)

Clockface::ClockworkEvent.create(
  name: "Example Event 2",
  description: "Runs the Example Event 2",
  command: "{\"class\":\"ExampleWorkerTwo\"}"
)
