require_relative "./config/boot"
require_relative "./config/environment"

require "clockface"

Clockface.sync_database_events(every: 10.seconds) do |event|
  # Each app can do anything they want here with the yielded event record
  # For this dummy app, we choose to store a hash in the `command` field
  # which we first parse and then use to construct a Sidekiq `perform_async`
  # statement. This could be adapated to fit any background schedule, like
  # ActiveJob, Rufus, etc..

  cmd_hash = JSON.parse(event.command)
  klass = cmd_hash["class"]

  logger = Logger.new(Rails.root.join("log", "example_workers.log"))
  klass.constantize.perform_async
end
