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
# Create Clockface Tasks
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

#
# Create Clockface Events
#

# rubocop:disable Style/IfUnlessModifier
tenant =
  if multi_tenancy_enabled?
    Clockface::Engine.config.clockface.tenant_list.first
  end
# rubocop:enable Style/IfUnlessModifier

event = Clockface::Event.new(
  task: Clockface::Task.first,
  enabled: true,
  skip_first_run: false,
  tenant: tenant,
  last_triggered_at: nil,
  period_value: 1,
  period_units: "hours",
  day_of_week: 0,
  hour: 12,
  minute: 0,
  time_zone: "Pacific Time (US & Canada)",
  if_condition: nil
)

# Bypass validation because model can't access
# `clockface_multi_tenancy_enabled?` that's called during the
# `before_validation` hook
event.save(validate: false)
