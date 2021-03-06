require "clockwork/database_events"
require_relative "../../../app/helpers/clockface/config_helper"
require_relative "../../../app/helpers/clockface/logging_helper"

# Loaded from lib/clockface as part of the clock configuration
#
# Clockwork doesn't support schema-based multi-tenancy by default. To acheive
# functionality we need to have it create a synch event for each individual
# tenant
#
# This overrides the Synchronizer class in the native Clockwork implementation
# to do the following -
#
#   1. If multi-tenancy is enabled, create a synch event for each tenant
#   2. If not, just create one synch event (same Clockwork functionality)

module Clockwork
  module DatabaseEvents
    class Synchronizer
      extend ::Clockface::ConfigHelper
      extend ::Clockface::LoggingHelper

      def self.setup(options = {}, &block_to_perform_on_event_trigger)
        every = options.fetch(:every) do
          raise KeyError, ":every must be set to the database sync frequency"
        end

        task_name = "sync_database_events"

        #
        # Multi-Tenant
        #

        if clockface_multi_tenancy_enabled?
          clockface_tenant_list.each do |t|
            event_store = EventStore.new(block_to_perform_on_event_trigger)

            Clockwork.manager.every(every, "#{t}.#{task_name}") do
              cmd = proc do
                # 1. Pre-load `:task` association so it doesn't need to be
                #    re-queried
                # 2. ActiveRecord lazily evaluates the query, so #all won't
                #    actually run against the DB when executed. Force it to
                #    execute by calling something on it (e.g. #to_a)
                Clockface::Event.
                  includes(:task).
                  all.
                  tap(&:to_a)
              end
              models = clockface_execute_in_tenant(t, cmd)

              clockface_log(:info, "[#{t}] Running #{t}.#{task_name}")
              event_store.update(models)
            end
          end

          return
        end

        #
        # Single Tenant
        #

        event_store = EventStore.new(block_to_perform_on_event_trigger)

        Clockwork.manager.every(every, task_name) do
          clockface_log(:info, "Running #{task_name}")
          event_store.update(Clockface::Event.all)
        end
      end
    end
  end
end
