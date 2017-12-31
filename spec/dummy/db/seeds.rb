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
# Create the Clockface Tasks
#

Clockface::Task.create(
  name: "Example Task 1",
  description: "Runs the Example Task 1",
  command: "{\"class\":\"ExampleWorkerOne\"}"
)

Clockface::Task.create(
  name: "Example Task 2",
  description: "Runs the Example Task 2",
  command: "{\"class\":\"ExampleWorkerTwo\"}"
)
