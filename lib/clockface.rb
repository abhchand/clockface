require "clockwork"
require "clockwork/database_events"

require_relative "./clockwork/database_events/synchronizer"
require_relative "../app/helpers/clockface/config_helper"
require_relative "../app/helpers/clockface/logging_helper"

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
#    each user and we want to take care of error handling, logging, and updating
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

      #
      # Configure Clockwork
      #

      Clockwork.manager.configure do |config|
        # The underlying Clockwork gem tries to set time zone in the following
        # order
        #
        #   a. Job-specific time
        #   b. Clockwork Configured time (Clockwork.manager.config[:tz])
        #   c. System Time
        #
        # Clockface enforces that each job *must* have a time zone. It defaults
        # to the `clockface_time_zone` when the user doesn't choose one.
        #
        # Clockface also sets the Clockwork configured time to be
        # `clockface_time_zone` in case for some reason a user updates the DB
        # record directly and bypasses our validations.
        #
        # Howevever this doesn't work as expected right now. See -
        #   https://github.com/Rykian/clockwork/issues/35
        #
        # As far as format, see explanation for time zone format in
        # `Clockface::ClockworkScheduledJob#tz`
        config[:tz] = ActiveSupport::TimeZone::MAPPING[clockface_time_zone]
      end

      clockwork_opts =
        { model: Clockface::ClockworkScheduledJob, every: opts[:every] }

      ::Clockwork::sync_database_events(clockwork_opts) do |job|
        job_name = "\"#{job.name}\" (ClockworkScheduledJob.id: #{job.id})"
        tenant_tag = "[#{job.tenant}] " if job.tenant

        if !job.enabled?
          clockface_log(:info, "#{tenant_tag}Skipping disabled Job #{job_name}")

          # This whole block is eventually invoked from
          # `Clockwork::Event#execute` using `block.call(...)`. Using `return`
          # inside a called object returns from the whole process, so we have
          # to use `next` instead to return from just the block itself
          # Further explanation: https://stackoverflow.com/a/1435781/2490003
          next
        end

        begin
          # We want to do 2 things here -
          #
          #   1. Update the timestamp. Do this before any job execution so
          #      that if this fails, we don't continue with execution
          #   2. Execute the job
          #
          #
          # In the case of multi-tenancy we want to execute both of the
          # above in the context of the correct tenant.

          clockface_log(:info, "#{tenant_tag}Running Job #{job_name}")

          cmd = Proc.new { job.update!(last_triggered_at: Time.zone.now) }

          if clockface_multi_tenancy_enabled?
            clockface_execute_in_tenant(job.tenant, cmd)
            clockface_execute_in_tenant(job.tenant, block, [job])
          else
            cmd.call
            yield(job)
          end
        rescue Exception => e
          clockface_log(
            :error,
            "#{tenant_tag}Error running Job #{job_name} -> #{e.message}"
          )
        end
      end
    end
  end

  extend ::Clockface::ConfigHelper
  extend ::Clockface::LoggingHelper
  extend Methods
end
