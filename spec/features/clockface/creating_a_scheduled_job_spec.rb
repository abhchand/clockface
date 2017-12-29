require "rails_helper"

module Clockface
  RSpec.feature "Creating a Scheduled Job", type: :feature do
    it "user can create a scheduled job" do
      events = create_list(:clockwork_event, 2)

      visit clockface.new_job_path

      # Fill In Form
      id = events[1].id
      select_option("clockwork_scheduled_job[clockface_clockwork_event_id]", id)
      find(:css, "#clockwork_scheduled_job_enabled").set(true)
      fill_in("clockwork_scheduled_job[period_value]", with: "13")
      select_option("clockwork_scheduled_job[period_units]", "hours")
      select_option("clockwork_scheduled_job[day_of_week]", "Tuesday")
      select_option("clockwork_scheduled_job[hour]", "17")
      select_option("clockwork_scheduled_job[minute]", "38")
      select_option("clockwork_scheduled_job[time_zone]", "Alaska")
      select_option("clockwork_scheduled_job[if_condition]", "weekday")

      expect do
        submit
      end.to change { Clockface::ClockworkScheduledJob.count }.by(1)

      # Validate model
      job = Clockface::ClockworkScheduledJob.last
      expect(job.clockface_clockwork_event_id).to eq(id)
      expect(job.enabled).to eq(true)
      expect(job.tenant).to be_nil
      expect(job.last_triggered_at).to be_nil
      expect(job.period_value).to eq(13)
      expect(job.period_units).to eq("hours")
      expect(job.day_of_week).to eq(2)
      expect(job.hour).to eq(17)
      expect(job.minute).to eq(38)
      expect(job.time_zone).to eq("Alaska")
      expect(job.if_condition).to eq("weekday")

      # Validate flash
      expect(page.find(".flash")).
        to have_content(t("clockface.jobs.create.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        events = create_list(:clockwork_event, 2)

        # Visit new jobs path
        visit clockface.jobs_path
        find(".jobs-index__new-btn").click

        # Fill In Form
        fill_in("clockwork_scheduled_job[period_value]", with: "-1")
        select_option("clockwork_scheduled_job[period_units]", "Hours")

        expect do
          submit
        end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.new_job_path)
        expect(page.find(".flash")).to have_content(
          t(
            "activerecord.errors.models.clockface/clockwork_scheduled_job."\
              "attributes.period_value.greater_than"
          ),
          count: 0
        )
      end
    end

    context "multi-tenancy is enabled", :multi_tenant do
      before(:each) do
        enable_multi_tenancy!
      end

      it "user can create scheduled jobs in multiple tenants" do
        tenant("earth") { create(:clockwork_event) }
        tenant("mars") { create(:clockwork_event) }

        with_subdomain("earth") do
          # Visit new jobs path
          visit clockface.new_job_path

          # Fill In Minmal Form
          fill_in("clockwork_scheduled_job[period_value]", with: "13")
          select_option("clockwork_scheduled_job[period_units]", "Hours")

          submit

          # Check count on both tenants
          expect(Clockface::ClockworkScheduledJob.count).to eq(1)
          tenant("mars") do
            expect(Clockface::ClockworkScheduledJob.count).to eq(0)
          end
        end

        with_subdomain("mars") do
          # Visit new jobs path
          visit clockface.new_job_path

          # Fill In Minmal Form
          fill_in("clockwork_scheduled_job[period_value]", with: "13")
          select_option("clockwork_scheduled_job[period_units]", "Hours")

          submit

          # Check count on both tenants
          expect(Clockface::ClockworkScheduledJob.count).to eq(1)
          tenant("earth") do
            expect(Clockface::ClockworkScheduledJob.count).to eq(1)
          end
        end
      end
    end

    def submit(opts = {})
      click_button(t("clockface.jobs.job_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end
  end
end
