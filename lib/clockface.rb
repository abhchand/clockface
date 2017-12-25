require "clockwork"
require "clockwork/database_events"

require_relative "./clockwork/database_events/synchronizer"
require_relative "../app/helpers/clockface/clockface_logging_helper"

require "clockface/engine"

# This file is the glue that ties together the clockwork gem with the Clockface
# Engine functionality.
#
# Clockface uses the `sync_database_events` method provided by Clockwork to
# periodically refresh the list of jobs from a DB table.
#
# In the case of multi-tenancy, there needs to be one refresh job for each
# individual tenant, but the same concept applies.
#
# Here's what happens -
#
# 1. Users require this file in their individual `clock.rb` files
#    which in turn loads the engine directly. The engine is called by Rails
#    during the startup process but we also need to load it here as part of the
#    environment that's loaded by the clock process
#
# 2. As mentioned above, Clockwork provides the `sync_database_events` method
#    as part of its API. However, we want to make things as easy as possible for
#    each user, and we want to take care of error handling, logging, and updating
#    records as well in a predictable fashion. The solution to that is to define
#    *another* custom `sync_database_events` below, which calls the original
#    Clockwork method. When users call `sync_database_events` it will hit this
#    wrapper which will take care of all the above tasks and defer execution to
#    the Clockwork method.
#
# 3. Clockwork doesn't support schema-based multi-tenancy. In order
#    to get that we need to override the Synchronizer it uses to create a synch
#    job for each individual tenant. That overriden synchronizer is loaded at
#    the top of this file. See that file for further background

module Clockface
  module Methods
    def sync_database_events(opts = {}, &block)
      ::Clockwork.manager = ::Clockwork::DatabaseEvents::Manager.new

      unless block_given?
        raise "Please specify a block to Clockface::sync_database_events"
      end

      ::Clockwork::sync_database_events(
        model: Clockface::ClockworkScheduledJob,
        every: opts[:every]
      ) do |job|
        if job.enabled?
          clockface_log(
            :info,
            "Running ClockworkScheduledJob id #{job.id} (\"#{job.name}\")"
          )

          begin
            yield(job)
          rescue Exception => e
            # Clockwork supports defining an error_handler block that gets
            # called when an error is raised. But we do our own error handling
            # here so that we can still update the `last_run_at` below
            clockface_log(
              :error,
              "Error while running ClockworkScheduledJob id "\
                "#{job.id} (\"#{job.name}\") => #{e.message}"
            )
          end

          job.update(last_run_at: Time.zone.now)
        else
          clockface_log(
            :info,
            "Skipping Disabled ClockworkScheduledJob id "\
              "#{job.id} (\"#{job.name}\")"
          )
        end
      end
    end
  end

  extend ::Clockface::ClockfaceLoggingHelper
  extend Methods
end
