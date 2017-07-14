Clockface::ClockworkEvent.create(
  name: "Example Event",
  description: "Runs the Example Event",
  command: "{\"class\":\"ExampleWorker\"}"
)

User.create!(
  first_name: "Shakuntala",
  last_name: "Devi",
  email: "Shakuntala.Devi@math.com",
  ability: "read_write"
)

User.create!(
  first_name: "Srinivasa",
  last_name: "Ramanujan",
  email: "Srinivasa.Ramanujan@math.com",
  ability: "read"
)
