require "rails_helper"

module Clockface
  RSpec.feature "Deleting a Scheduled Job", type: :feature do
    it "user can delete a scheduled job" do
      tasks = create_list(:task, 2)

      job = create(:clockwork_scheduled_job, task: tasks[1])
      other_job = create(:clockwork_scheduled_job, task: tasks[0])

      visit clockface.job_delete_path(job)

      # Fill In Captcha
      fill_in("captcha", with: captcha_for(job))

      expect do
        submit
      end.to change { Clockface::ClockworkScheduledJob.count }.by(-1)

      # Validate model no longer exists
      expect { job.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # Validate other job not touched
      old_attrs = other_job.attributes
      new_attrs = other_job.reload.attributes
      expect(old_attrs).to eq(new_attrs)
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        job = create(:clockwork_scheduled_job)

        # Visit new jobs path
        visit clockface.job_delete_path(job)

        # Fill In Bad CAPTCHA
        fill_in("captcha", with: "foo")

        expect do
          submit
        end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.job_delete_path(job))
        expect(page.find(".flash")).to have_content(
          t("clockface.jobs.destroy.validation.incorrect_captcha")
        )
      end
    end

    context "multi-tenancy is enabled", :multi_tenant do
      before(:each) do
        enable_multi_tenancy!
      end

      it "user can delete scheduled jobs in multiple tenants" do
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
          visit clockface.job_delete_path(earth_job)

          # Delete Job
          fill_in("captcha", with: captcha_for(earth_job))

          submit

          # Check records on both tenants
          expect(Clockface::ClockworkScheduledJob.count).to eq(0)
          tenant("mars") do
            expect(Clockface::ClockworkScheduledJob.count).to eq(1)
          end
        end

        with_subdomain("mars") do
          # Visit new jobs path
          visit clockface.job_delete_path(mars_job)

          # Delete Job
          fill_in("captcha", with: captcha_for(mars_job))

          submit

          # Check records on both tenants
          expect(Clockface::ClockworkScheduledJob.count).to eq(0)
          tenant("earth") do
            expect(Clockface::ClockworkScheduledJob.count).to eq(0)
          end
        end
      end
    end

    def submit
      click_button(t("clockface.jobs.delete.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end

    def captcha_for(job)
      Digest::SHA1.hexdigest(job.id.to_s).
        first(Clockface::JobsController::CAPTCHA_LENGTH)
    end
  end
end
