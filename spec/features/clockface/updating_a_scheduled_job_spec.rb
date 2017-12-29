require "rails_helper"

module Clockface
  RSpec.feature "Updating a Scheduled Job", type: :feature do
    it "user can update a scheduled job" do
      events = create_list(:clockwork_event, 2)
      job = create(
        :clockwork_scheduled_job,
        event: events[1],
        enabled: false,
        period_value: 99,
        period_units: "seconds",
        day_of_week: 5,
        hour: 22,
        minute: 32,
        time_zone: "Samoa",
        if_condition: "odd_week"
      )
      other_job = create(:clockwork_scheduled_job, event: events[0])

      visit clockface.edit_job_path(job)

      # Fill In Form
      find(:css, "#clockwork_scheduled_job_enabled").set(true)
      fill_in("clockwork_scheduled_job[period_value]", with: "13")
      select_option("clockwork_scheduled_job[period_units]", "Hours")
      select_option("clockwork_scheduled_job[day_of_week]", "Tuesday")
      select_option("clockwork_scheduled_job[hour]", "17")
      select_option("clockwork_scheduled_job[minute]", "38")
      select_option("clockwork_scheduled_job[time_zone]", "Alaska")
      select_option("clockwork_scheduled_job[if_condition]", "weekday")

      expect do
        submit
      end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

      # Validate model
      job.reload
      expect(job.clockface_clockwork_event_id).to eq(events[1].id)
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

      # Validate other job not touched
      old_attrs = other_job.attributes
      new_attrs = other_job.reload.attributes
      expect(old_attrs).to eq(new_attrs)

      # Validate flash
      expect(page.find(".flash")).
        to have_content(t("clockface.jobs.update.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        job = create(:clockwork_scheduled_job)

        # Visit new jobs path
        visit clockface.edit_job_path(job)

        # Fill In Form
        fill_in("clockwork_scheduled_job[period_value]", with: "-1")
        select_option("clockwork_scheduled_job[period_units]", "Hours")

        expect do
          submit
        end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.edit_job_path(job))
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

      it "user can update scheduled jobs in multiple tenants" do
        earth_job =
          tenant("earth") do
            create(:clockwork_scheduled_job, period_units: "seconds")
          end

        mars_job =
          tenant("mars") do
            create(:clockwork_scheduled_job, period_units: "seconds")
          end

        with_subdomain("earth") do
          # Visit new jobs path
          visit clockface.edit_job_path(earth_job)

          # Update records
          select_option("clockwork_scheduled_job[period_units]", "Hours")

          submit

          # Check records on both tenants
          expect(Clockface::ClockworkScheduledJob.first.period_units).
            to eq("hours")
          tenant("mars") do
            expect(Clockface::ClockworkScheduledJob.first.period_units).
              to eq("seconds")
          end
        end

        with_subdomain("mars") do
          # Visit new jobs path
          visit clockface.edit_job_path(mars_job)

          # Update records
          select_option("clockwork_scheduled_job[period_units]", "Hours")

          submit

          # Check records on both tenants
          expect(Clockface::ClockworkScheduledJob.first.period_units).
            to eq("hours")
          tenant("earth") do
            expect(Clockface::ClockworkScheduledJob.first.period_units).
              to eq("hours")
          end
        end
      end
    end

    def submit
      click_button(t("clockface.jobs.job_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end
  end
end
