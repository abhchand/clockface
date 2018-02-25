require "rails_helper"

module Clockface
  RSpec.feature "Clockwork Integration", type: :feature do
    include Clockface::Engine.routes.url_helpers

    let(:epoch) do
      # See the note in `lib/clockface` about how we set time zone to ensure
      # that Clockwork never relies on local system time. So what we set here
      # shouldn't matter, functionally speaking
      #
      # But for our specs it's easiest to work with UTC, so pretend our
      # local time is UTC. This has the added bonus of mimicing the local
      # environment found on most deployment servers
      Time.parse("2017-01-01 00:00:00 UTC")
    end
    let(:sync_period) { 3.seconds }

    before { setup }

    after(:each) { Clockwork.clear! }

    shared_examples "triggers events" do
      it "triggers a event" do
        tick(1, expect: { sync: true })

        event = new_event(every: 2.seconds)

        # rubocop:disable Layout/ExtraSpacing
        tick(2)
        tick(3)
        tick(4,  expect_to_trigger: { sync: true })
        tick(5,  expect_to_trigger: { events: [event] })
        tick(6)
        tick(7,  expect_to_trigger: { sync: true, events: [event] })
        tick(8)
        tick(9,  expect_to_trigger: { events: [event] })
        tick(10, expect_to_trigger: { sync: true })
        tick(11, expect_to_trigger: { events: [event] })
        # rubocop:enable Layout/ExtraSpacing
      end

      it "triggers multiple events" do
        task1 = new_task(type: 1)
        task2 = new_task(type: 2)

        event1 = new_event(every: 3.seconds, task: task1)
        event2 = new_event(every: 2.seconds, task: task2)
        event3 = new_event(every: 1.seconds, task: task1)

        tick(1,  expect_to_trigger: { sync: true })
        tick(2,  expect_to_trigger: { events: [event3, event2, event1] })
        tick(3,  expect_to_trigger: { events: [event3] })
        tick(4,  expect_to_trigger: { events: [event3, event2], sync: true })
        tick(5,  expect_to_trigger: { events: [event3, event1] })
        tick(6,  expect_to_trigger: { events: [event3, event2] })
        tick(7,  expect_to_trigger: { events: [event3], sync: true })
        tick(8,  expect_to_trigger: { events: [event3, event2, event1] })
        tick(9,  expect_to_trigger: { events: [event3] })
        tick(10, expect_to_trigger: { events: [event3, event2], sync: true })
        tick(11, expect_to_trigger: { events: [event3, event1] })
      end
    end

    it_behaves_like "triggers events"

    it "correctly handles changes to the task" do
      event = new_event(every: 3.seconds, task: new_task(type: 1))

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { events: [event] })
      tick(3)

      event.update!(task: new_task(type: 2))

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { events: [event] })

      # Explicit confirmation that the new task was picked up
      expect(ExampleWorkerOne.jobs.count).to eq(0)
      expect(ExampleWorkerTwo.jobs.count).to eq(1)
    end

    it "correctly handles changes to the enabled flag" do
      event = new_event(every: 3.seconds, enabled: true)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { events: [event] })
      tick(3)

      event.update!(enabled: false)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { events: [] })
      tick(6)

      event.update!(enabled: true)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { events: [event] })
    end

    it "correctly handles changes to the period" do
      event = new_event(every: 3.seconds)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { events: [event] })
      tick(3)

      event.update!(period_value: 1)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { events: [event] })
      tick(6, expect_to_trigger: { events: [event] })
    end

    it "correctly handles changes to the 'at' configuration" do
      # Epoch:
      #
      #   UTC:        2017-01-01 00:00:00 (Sunday)
      #   Pacific:    2016-12-31 16:00:00 (Saturday)

      event = new_event(every: 3.seconds, day_of_week: 6, hour: 15, minute: nil)

      tick(-3, expect_to_trigger: { sync: true })
      tick(-2, expect_to_trigger: { events: [event] })
      tick(-1)
      tick(0, expect_to_trigger: { sync: true })

      # Hour has changed from 15:00 to 16:00, so event should no longer trigger
      tick(1, expect_to_trigger: { events: [] })
      tick(2)

      # Re-enable event to run on hour 16:00
      event.update!(hour: 16)
      tick(3, expect_to_trigger: { sync: true })
      tick(4, expect_to_trigger: { events: [event] })
    end

    it "correctly handles changes to the time zone" do
      # Epoch:
      #
      #   UTC:        2017-01-01 00:00:00 (Sunday)
      #   Eastern:    2016-12-31 19:00:00 (Saturday)
      #   Pacific:    2016-12-31 16:00:00 (Saturday)

      tz1 = "Eastern Time (US & Canada)"
      tz2 = "Pacific Time (US & Canada)"

      # Since the event only runs at `hour: 19`, it should stop running when the
      # time zone changes to Pacific since it is 3 hours behind
      event = new_event(every: 3.seconds, time_zone: tz1, hour: 19)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { events: [event] })
      tick(3)

      event.update!(time_zone: tz2)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { events: [] })
      tick(6)

      event.update!(time_zone: tz1)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { events: [event] })
    end

    it "correctly handles changes to the 'if' condition" do
      event = new_event(every: 3.seconds, if: :even_week)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { events: [event] })
      tick(3)

      event.update!(if_condition: :odd_week)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { events: [] })
      tick(6)

      event.update!(if_condition: :even_week)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { events: [event] })
    end

    context "multi tenancy is enabled" do
      before do
        enable_multi_tenancy!

        # Re-run setup because multi tenancy is now enabled
        setup

        tenant("earth")
      end

      it_behaves_like "triggers events"

      it "triggers multiple events across multiple tenants" do
        task1 = tenant("earth") { new_task(type: 1) }
        task2 = tenant("mars") { new_task(type: 2) }

        event1 = tenant("earth") { new_event(every: 3.seconds, task: task1) }
        event2 = tenant("mars") { new_event(every: 2.seconds, task: task2) }

        tick(1,  expect_to_trigger: { sync: true })
        tick(2,  expect_to_trigger: { events: [event2, event1] })
        tick(3,  expect_to_trigger: { events: [] })
        tick(4,  expect_to_trigger: { events: [event2], sync: true })
        tick(5,  expect_to_trigger: { events: [event1] })
        tick(6,  expect_to_trigger: { events: [event2] })
      end
    end

    describe "scheduling Clockwork tasks outside of database" do
      it "works in parrallel with any tasks hard-coded in a Clockfile" do
        task1 = new_task(type: 1)

        event1 = new_event(every: 3.seconds, task: task1)

        # Schedule a static event with `every` and then extract it from the
        # list of tasks
        Clockwork.manager.every(3.seconds, "static.event") do
          ExampleWorkerTwo.perform_async(2)
        end

        event2 = Clockwork.manager.instance_variable_get(:@events).detect do |e|
          e.job == "static.event"
        end

        # 1. Unlike database tasks, event2 will run immediately because it
        #    doesn't need to sync from the DB.
        # 2. Also, we can't use the `expect_to_trigger` helper because the
        #    events have a very different data structure. Settle for testing it
        #    directly

        tick(1, expect_to_trigger: { sync: true, events: [] })
        expect(event2.last).to eq(epoch + 1.second)
        expect(ExampleWorkerTwo.jobs.count).to eq(1)
        tick(2, expect_to_trigger: { events: [event1] })
        tick(3)
        tick(4, expect_to_trigger: { sync: true, events: [] })
        expect(event2.last).to eq(epoch + 4.second)
        expect(ExampleWorkerTwo.jobs.count).to eq(1)
        tick(5, expect_to_trigger: { events: [event1] })
      end
    end

    def setup
      Clockwork.clear!

      Clockface.sync_database_events(every: sync_period) do |event|
        cmd_hash = JSON.parse(event.command)
        klass = cmd_hash["class"]
        args = cmd_hash["args"]

        klass.constantize.perform_async(*args)
      end

      # `sync_database_events` resets `Clockwork.manger`, so this config
      # needs to happen after the above
      Clockwork.manager.configure do |clockwork_config|
        # Clockwork logs to STDOUT by default
        clockwork_config[:logger] = Logger.new("/dev/null")
      end
    end

    def tick(seconds_elapsed, opts = {})
      # Clear any state from previous `tick`
      Sidekiq::Worker.clear_all

      # Stub `Time.zone.now` to return `epoch + seconds_elapsed` for the
      # of the Clockwork `tick` method so that we can do things like verify
      # the value of `last_triggered_at` deterministically .
      # This is slightly shifty because we're returning a `Time` object instead
      # of `ActiveSupport::TimeWithZone`, but it works for our simple setup.
      # If it gets any more complex, consider using a gem like Timecop to
      # stub time
      stub_active_support_time!(seconds_elapsed)
      Clockwork.manager.tick(epoch + seconds_elapsed.seconds)
      unstub_active_support_time!(seconds_elapsed)

      events = opts[:expect_to_trigger].try(:[], :events)
      expect_events_did_trigger(events, seconds_elapsed) if events.present?

      sync = opts[:expect_to_trigger].try(:[], :sync)
      expect_sync_did_trigger(seconds_elapsed) if sync.present?
    end

    def new_event(opts = {})
      if opts.key?(:every)
        opts[:period_value] = opts.delete(:every) / 1.second
        opts[:period_units] = "seconds"
      end

      create(
        :event,
        {
          # Go ahead and use task if specified in the args so we don't create
          # a new record
          task: opts[:task] || new_task(type: 1),
          tenant: nil,
          period_value: 1,
          period_units: "seconds",
          day_of_week: nil,
          hour: nil,
          minute: nil,
          time_zone: nil,
          if_condition: nil
        }.merge(opts)
      )
    end

    def new_task(opts = {})
      # For specs, limit our selves to creating tasks based on ExampleWorkerOne
      # or ExampleWorkerTwo - identified by argument type 1 or 2
      type = opts.fetch(:type)
      raise ":type must be 1 or 2" unless [1, 2].include?(type)

      klass = type == 1 ? "ExampleWorkerOne" : "ExampleWorkerTwo"
      args = type == 1 ? 1234 : 4567

      create(
        :task,
        name: "Example #{type}",
        command: "{\"class\":\"#{klass}\",\"args\":[#{args}]}"
      )
    end

    def expect_events_did_trigger(events, seconds_elapsed)
      expected_events = events.map do |event|
        cmd_hash = JSON.parse(event.task.command)
        {
          "class" => cmd_hash["class"],
          "args" => cmd_hash["args"],
          "tenant" => event.tenant
        }
      end

      actual_events = Sidekiq::Queues["default"].map do |event|
        {
          "class" => event["class"],
          "args" => event["args"],
          "tenant" =>
            # The apartment gem / tenant functionality is enabled for all specs,
            # and we acheive "single tenancy" by stubbing/mocking configs. So
            # `apartment-sidekiq` still marks the event as being in the "public"
            # tenant. Catch this specific case and mark it as `nil` so it
            # matches the `event.tenant` value, which will be nil for single
            # tenancy
            if clockface_single_tenancy_enabled? &&
                event["apartment"] == "public"
              nil
            else
              event["apartment"]
            end
        }
      end

      expect(actual_events).to match_array(expected_events)
      events.each do |event|
        expect(reload_event(event).last_triggered_at).
          to eq(epoch + seconds_elapsed)
      end
    end

    def expect_sync_did_trigger(seconds_elapsed)
      # `Clockwork::Event` stores its last runtime in `@last`
      last_ran_at = Clockwork.manager.instance_variable_get(:@events)[0].last
      now = epoch + seconds_elapsed.seconds

      seconds_elapsed == 1 && last_ran_at.nil? ||
        (last_ran_at - now).abs < 1.second
    end

    def stub_active_support_time!(seconds_elapsed)
      allow_any_instance_of(ActiveSupport::TimeZone).to receive(:now) do
        epoch + seconds_elapsed
      end
    end

    def unstub_active_support_time!(seconds_elapsed)
      allow_any_instance_of(ActiveSupport::TimeZone).
        to receive(:now).and_call_original
    end

    def reload_event(event)
      # 1. If multi tenant, reload the event within context of its own tenant
      # 2. Pre-load the `task` association in memory for the same reason we do
      #    in the Synchronizer called by `setup`

      if clockface_multi_tenancy_enabled?
        tenant(event.tenant) { event.reload.tap(&:task) }
      else
        event.reload.tap(&:task)
      end
    end
  end
end
