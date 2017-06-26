require_relative "./config/boot"
require_relative "./config/environment"

require "clockface"

module Clockface
  sync_database_events(every: 1.minute) do |job|
    JSON.parse(job.command)["class"].constantize.perform_async(99)
  end
end
