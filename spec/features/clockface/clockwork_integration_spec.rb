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
        task1 = new_task(type: 1)
        task2 = new_task(type: 2)

        job1 = new_job(every: 3.seconds, task: task1)
        job2 = new_job(every: 2.seconds, task: task2)
        job3 = new_job(every: 1.seconds, task: task1)

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

    it "correctly handles changes to the task" do
      job = new_job(every: 3.seconds, task: new_task(type: 1))

      tick(1, expect_to_trigger: { sync: true })
      tick(2, expect_to_trigger: { jobs: [job] })
      tick(3)

      job.update!(task: new_task(type: 2))

      tick(4, expect_to_trigger: { sync: true })
      tick(5, expect_to_trigger: { jobs: [job] })

      # Explicit confirmation that the new task was picked up
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
      # Epoch:
      #
      #   UTC:        2017-01-01 00:00:00 (Sunday)
      #   Pacific:    2016-12-31 16:00:00 (Saturday)

      job = new_job(every: 3.seconds, day_of_week: 6, hour: 15, minute: nil)

      tick(-3, expect_to_trigger: { sync: true })
      tick(-2, expect_to_trigger: { jobs: [job] })
      tick(-1)
      tick(0, expect_to_trigger: { sync: true })

      # Hour has changed from 15:00 to 16:00, so job should no longer trigger
      tick(1, expect_to_trigger: { jobs: [] })
      tick(2)

      # Re-enable job to run on hour 16:00
      job.update!(hour: 16)
      tick(3, expect_to_trigger: { sync: true })
      tick(4, expect_to_trigger: { jobs: [job] })
    end

    it "correctly handles changes to the time zone" do
      # Epoch:
      #
      #   UTC:        2017-01-01 00:00:00 (Sunday)
      #   Eastern:    2016-12-31 19:00:00 (Saturday)
      #   Pacific:    2016-12-31 16:00:00 (Saturday)

      tz1 = "Eastern Time (US & Canada)"
      tz2 = "Pacific Time (US & Canada)"

      # Since the job only runs at `hour: 19`, it should stop running when the
      # time zone changes to Pacific since it is 3 hours behind
      job = new_job(every: 3.seconds, time_zone: tz1, hour: 19)

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
        task1 = tenant("earth") { new_task(type: 1) }
        task2 = tenant("mars") { new_task(type: 2) }

        job1 = tenant("earth") { new_job(every: 3.seconds, task: task1) }
        job2 = tenant("mars") { new_job(every: 2.seconds, task: task2) }

        tick(1,  expect_to_trigger: { sync: true })
        tick(2,  expect_to_trigger: { jobs: [job2, job1] })
        tick(3,  expect_to_trigger: { jobs: [] })
        tick(4,  expect_to_trigger: { jobs: [job2], sync: true })
        tick(5,  expect_to_trigger: { jobs: [job1] })
        tick(6,  expect_to_trigger: { jobs: [job2] })
      end
    end

    describe "scheduling Clockwork tasks outside of database" do
      it "works in parrallel with any tasks hard-coded in a Clockfile" do
        task1 = new_task(type: 1)

        job1 = new_job(every: 3.seconds, task: task1)

        # Schedule a static job with `every` and then extract it from the
        # list of tasks
        Clockwork.manager.every(3.seconds, "static.job") do
          ExampleWorkerTwo.perform_async(2)
        end

        job2 = Clockwork.manager.instance_variable_get(:@events).detect do |e|
          e.job == "static.job"
        end

        # 1. Unlike database tasks, job2 will run immediately because it
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

      jobs = opts[:expect_to_trigger].try(:[], :jobs)
      expect_jobs_did_trigger(jobs, seconds_elapsed) if jobs.present?

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

    def expect_jobs_did_trigger(jobs, seconds_elapsed)
      expected_jobs = jobs.map do |job|
        cmd_hash = JSON.parse(job.task.command)
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
      jobs.each do |job|
        expect(reload_job(job).last_triggered_at).to eq(epoch + seconds_elapsed)
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

    def reload_job(job)
      # 1. If multi tenant, reload the job within the context of its own tenant
      # 2. Pre-load the `task` association in memory for the same reason we do
      #    in the Synchronizer called by `setup`

      if clockface_multi_tenancy_enabled?
        tenant(job.tenant) { job.reload.tap(&:task) }
      else
        job.reload.tap(&:task)
      end
    end

  end
end
