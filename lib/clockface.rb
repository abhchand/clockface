require "clockwork"
require "clockwork/database_events"

require "clockface/engine"

module Clockface
  module Methods
    def sync_database_events(opts = {}, &block)
      ::Clockwork.manager = ::Clockwork::DatabaseEvents::Manager.new
      logger = Clockface::Engine.config.clockface.logger

      unless block_given?
        raise "Please specify a block to Clockface::sync_database_events"
      end

      ::Clockwork::sync_database_events(model: Clockface::ClockworkScheduledJob, every: opts[:every]) do |job|
        if job.enabled?
          logger.info "[Clockface] Running Job #{job.id} (#{job.name})"
          yield(job)
          job.update(last_run_at: Time.zone.now)
        else
          logger.info "[Clockface] Skipping Disabled Job #{job.id} (#{job.name})"
        end
      end
    end
  end

  extend Methods
end
