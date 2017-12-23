require "clockwork"
require "clockwork/database_events"

require "clockface/engine"

module Clockface
  module Methods
    # Override the `sync_database_events` helper that's provided by the core
    # Clockwork gem. This acts as a wrapper and ultimately calls the original
    # method, but it also logs events as they happen

    def sync_database_events(opts = {}, &block)
      ::Clockwork.manager = ::Clockwork::DatabaseEvents::Manager.new
      logger = Clockface::Engine.config.clockface.logger

      unless block_given?
        raise "Please specify a block to Clockface::sync_database_events"
      end

      ::Clockwork::sync_database_events(
        model: Clockface::ClockworkScheduledJob,
        every: opts[:every]
      ) do |job|
        if job.enabled?
          logger.info(
            "[Clockface] Running ClockworkScheduledJob id "\
              "#{job.id} (\"#{job.name}\")"
          )

          begin
            yield(job)
          rescue Exception => e
            # Clockwork supports defining an error_handler block that gets
            # called when an error is raised. But we do our own error handling
            # here so that we can still update the `last_run_at` below
            logger.error(
              "[Clockface] Error while running ClockworkScheduledJob id "\
                "#{job.id} (\"#{job.name}\") => #{e.message}"
            )
          end

          job.update(last_run_at: Time.zone.now)
        else
          logger.info(
            "[Clockface] Skipping Disabled ClockworkScheduledJob id "\
              "#{job.id} (\"#{job.name}\")"
          )
        end
      end
    end
  end

  extend Methods
end
