require "rails_helper"

module Clockface
  RSpec.feature "Clockwork Integration", type: :feature do
    include Clockface::Engine.routes.url_helpers

    let(:epoch) { Time.parse("Jan 01 2017") }
    let(:sync_period) { 3.seconds }

    before(:each) { setup }

    after(:each) { Clockwork.clear! }

    shared_examples "triggers scheduled jobs" do
      it "triggers a scheduled job" do
        tick(1, expect: { sync: true })

        job = new_job(every: 2.seconds)

        # rubocop:disable Layout/ExtraSpacing
        tick(2)
        tick(3)
        tick(4,  expect_to_trigger: { sync: true })
        tick(5,  expect_to_trigger: { jobs: [job] })
        tick(6)
        tick(7,  expect_to_trigger: { sync: true, jobs: [job] })
        tick(8)
        tick(9,  expect_to_trigger: { jobs: [job] })
        tick(10, expect_to_trigger: { sync: true })
        tick(11, expect_to_trigger: { jobs: [job] })
        # rubocop:enable Layout/ExtraSpacing
      end

      it "triggers multiple scheduled jobs" do
        event1 = new_event(type: 1)
        event2 = new_event(type: 2)

        job1 = new_job(every: 3.seconds, event: event1)
        job2 = new_job(every: 2.seconds, event: event2)
        job3 = new_job(every: 1.seconds, event: event1)

        tick(1,  expect_to_trigger: { sync: true })
        tick(2,  expect_to_trigger: { jobs: [job3, job2, job1] })
        tick(3,  expect_to_trigger: { jobs: [job3] })
        tick(4,  expect_to_trigger: { jobs: [job3, job2], sync: true })
        tick(5,  expect_to_trigger: { jobs: [job3, job1] })
        tick(6,  expect_to_trigger: { jobs: [job3, job2] })
        tick(7,  expect_to_trigger: { jobs: [job3], sync: true })
        tick(8,  expect_to_trigger: { jobs: [job3, job2, job1] })
        tick(9,  expect_to_trigger: { jobs: [job3] })
        tick(10, expect_to_trigger: { jobs: [job3, job2], sync: true })
        tick(11, expect_to_trigger: { jobs: [job3, job1] })
      end
    end

    it_behaves_like "triggers scheduled jobs"

    it "correctly handles changes to the event" do
      job = new_job(every: 3.seconds, event: new_event(type: 1))

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(event: new_event(type: 2))

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [job] })

      # Explicit confirmation that the new event was picked up
      expect(ExampleWorkerOne.jobs.count).to eq(0)
      expect(ExampleWorkerTwo.jobs.count).to eq(1)
    end

    it "correctly handles changes to the enabled flag" do
      job = new_job(every: 3.seconds, enabled: true)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(enabled: false)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [] })
      tick(6)

      job.update!(enabled: true)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { jobs: [job] })
    end

    it "correctly handles changes to the period" do
      job = new_job(every: 3.seconds)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(period_value: 1)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [job] })
      tick(6, expect_to_trigger: { jobs: [job] })
    end

    it "correctly handles changes to the 'at' configuration" do
      # Jan 01 2017 was a Sunday (0) making the preceding day a Saturday (6)
      job = new_job(every: 3.seconds, day_of_week: 6, hour: 23, minute: nil)

      tick(-3, expect_to_trigger: { sync: true })
      tick(-2, expect_to_trigger: { jobs: [job] })
      tick(-1)
      tick(0, expect_to_trigger: { sync: true })

      # Day has changed to Sunday, so job should no longer trigger
      tick(1, expect_to_trigger: { jobs: [] })
      tick(2)

      # Re-enable job to run on Sundays
      job.update!(day_of_week: 0, hour: 0)
      tick(3, expect_to_trigger: { sync: true })
      tick(4, expect_to_trigger: { jobs: [job] })
    end

    it "correctly handles changes to the time zone" do
      tz1 = "Eastern Time (US & Canada)"
      tz2 = "Pacific Time (US & Canada)"

      # Since the job only runs at `hour: 0`, it should stop running when the
      # time zone changes to Pacific since it is 3 hours behind
      job = new_job(every: 3.seconds, time_zone: tz1, hour: 0)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(time_zone: tz2)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [] })
      tick(6)

      job.update!(time_zone: tz1)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { jobs: [job] })
    end

    it "correctly handles changes to the 'if' condition" do
      job = new_job(every: 3.seconds, if: :even_week)

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(if_condition: :odd_week)

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [] })
      tick(6)

      job.update!(if_condition: :even_week)

      tick(7, expect_to_trigger: { sync: true })
      tick(8, expect_to_trigger: { jobs: [job] })
    end

    context "multi tenancy is enabled" do
      before(:each) do
        enable_multi_tenancy!

        # Re-run setup because multi tenancy is now enabled
        setup

        tenant("earth")
      end

      it_behaves_like "triggers scheduled jobs"

      it "triggers multiple scheduled jobs across multiple tenants" do
        event1 = tenant("earth") { new_event(type: 1) }
        event2 = tenant("mars") { new_event(type: 2) }

        job1 = tenant("earth") { new_job(every: 3.seconds, event: event1) }
        job2 = tenant("mars") { new_job(every: 2.seconds, event: event2) }

        tick(1,  expect_to_trigger: { sync: true })
        tick(2,  expect_to_trigger: { jobs: [job2, job1] })
        tick(3,  expect_to_trigger: { jobs: [] })
        tick(4,  expect_to_trigger: { jobs: [job2], sync: true })
        tick(5,  expect_to_trigger: { jobs: [job1] })
        tick(6,  expect_to_trigger: { jobs: [job2] })
      end
    end

    describe "scheduling Clockwork events outside of database" do
      it "works in parrallel with any events hard-coded in a Clockfile" do
        event1 = new_event(type: 1)

        job1 = new_job(every: 3.seconds, event: event1)

        # Schedule a static job with `every` and then extract it from the
        # list of events
        Clockwork.manager.every(3.seconds, "static.job") do
          ExampleWorkerTwo.perform_async(2)
        end

        job2 = Clockwork.manager.instance_variable_get(:@events).detect do |e|
          e.job == "static.job"
        end

        # 1. Unlike database events, job2 will run immediately because it
        #    doesn't need to sync from the DB.
        # 2. Also, we can't use the `expect_to_trigger` helper because the jobs
        #    have a very different data structure. Settle for testing it
        #    directly

        tick(1, expect_to_trigger: { sync: true, jobs: [] })
        expect(job2.last).to eq(epoch + 1.second)
        expect(ExampleWorkerTwo.jobs.count).to eq(1)
        tick(2, expect_to_trigger: { jobs: [job1] })
        tick(3)
        tick(4, expect_to_trigger: { sync: true, jobs: [] })
        expect(job2.last).to eq(epoch + 4.second)
        expect(ExampleWorkerTwo.jobs.count).to eq(1)
        tick(5, expect_to_trigger: { jobs: [job1] })
      end
    end

    def setup
      Clockwork.clear!

      Clockface.sync_database_events(every: sync_period) do |job|
        cmd_hash = JSON.parse(job.command)
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

      Clockwork.manager.tick(epoch + seconds_elapsed.seconds)

      jobs = opts[:expect_to_trigger].try(:[], :jobs)
      expect_jobs_did_trigger(jobs) if jobs.present?

      sync = opts[:expect_to_trigger].try(:[], :sync)
      expect_sync_did_trigger(seconds_elapsed) if sync.present?
    end

    def new_job(opts = {})
      if opts.key?(:every)
        opts[:period_value] = opts.delete(:every) / 1.second
        opts[:period_units] = "seconds"
      end

      create(
        :clockwork_scheduled_job,
        {
          # Go ahead and use event if specified in the args so we don't create
          # a new record
          event: opts[:event] || new_event(type: 1),
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

    def new_event(opts = {})
      # For specs, limit our selves to creating events based on ExampleWorkerOne
      # or ExampleWorkerTwo - identified by argument type 1 or 2
      type = opts.fetch(:type)
      raise ":type must be 1 or 2" unless [1, 2].include?(type)

      klass = type == 1 ? "ExampleWorkerOne" : "ExampleWorkerTwo"
      args = type == 1 ? 1234 : 4567

      create(
        :clockwork_event,
        name: "Example #{type}",
        command: "{\"class\":\"#{klass}\",\"args\":[#{args}]}"
      )
    end

    def expect_jobs_did_trigger(jobs)
      expected_jobs = jobs.map do |job|
        cmd_hash = JSON.parse(job.event.command)
        {
          "class" => cmd_hash["class"],
          "args" => cmd_hash["args"],
          "tenant" => job.tenant
        }
      end

      actual_jobs = Sidekiq::Queues["default"].map do |job|
        {
          "class" => job["class"],
          "args" => job["args"],
          "tenant" =>
            # The apartment gem / tenant functionality is enabled for all specs,
            # and we acheive "sing tenancy" by stubbing/mocking configs. So
            # `apartment-sidekiq` still marks the job as being in the "public"
            # tenant. Catch this specific case and mark it as `nil` so it
            # matches the `job.tenant` value, which will be nil for single
            # tenancy
            if clockface_single_tenancy_enabled? && job["apartment"] == "public"
              nil
            else
              job["apartment"]
            end
        }
      end

      expect(actual_jobs).to match_array(expected_jobs)
    end

    def expect_sync_did_trigger(seconds_elapsed)
      # `Clockwork::Event` stores its last runtime in `@last`
      last_ran_at = Clockwork.manager.instance_variable_get(:@events)[0].last
      now = epoch + seconds_elapsed.seconds

      seconds_elapsed == 1 && last_ran_at.nil? ||
        (last_ran_at - now).abs < 1.second
    end
  end
end
