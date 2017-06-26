require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/delete.html.erb", type: :view do
    let(:job) { Clockface::JobsPresenter.new(create(:clockwork_scheduled_job)) }
    let(:captcha) { "abcde" }

    before(:each) do
      job
      assign(:job, job)
      assign(:captcha, captcha)
      view.extend ClockfaceConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.jobs.delete.heading").downcase)
    end

    it "displays the warning" do
      render
      expect(page.find(".jobs-delete__warning.alert-danger")).
        to have_content(t("clockface.jobs.delete.warning"))
    end

    describe "job detail" do
      shared_examples "displayed job field" do |field_name|
        it "displays the field_value" do
          render

          field_label =
            Clockface::ClockworkScheduledJob.human_attribute_name(field_name)
          field_value = job.send(field_name)
          field_value = strip_tags(field_value) if field_value.is_a?(String)

          row = page.find(".jobs-delete__job-detail-element--#{field_name}")

          expect(row.find("label")).to have_content(field_label)
          expect(row).to have_content(field_value)
        end
      end

      before(:each) do
        # Ensure each job field has a non-nil value so the view test is
        # valid

        # Some fields are not populated by the factor, so update manually
        job.update(if_condition: "odd_week")
        job.update(last_run_at: 1.day.ago)


        # Run a sanity check to make sure every field is not nil, should the
        # factory ever change in the future
        %w(
          period_value
          period_units
          day_of_week
          hour
          minute
          time_zone
          if_condition
          last_run_at
        ).each do |attr|
          raise "#{attr} can not be nil!" if job.send(attr).blank?
        end
      end

      it_behaves_like "displayed job field", :id
      it_behaves_like "displayed job field", :name
      it_behaves_like "displayed job field", :period
      it_behaves_like "displayed job field", :at
      it_behaves_like "displayed job field", :time_zone
      it_behaves_like "displayed job field", :if_condition
      it_behaves_like "displayed job field", :last_run_at

      describe "enabled field" do
        context "job is enabled" do
          before(:each) { job.update(enabled: true) }

          it "displays the enabled icon with CSS status" do
            render

            field_label =
              Clockface::ClockworkScheduledJob.human_attribute_name("enabled")

            row = page.find(".jobs-delete__job-detail-element--enabled")

            expect(row.find("label")).to have_content(field_label)
            expect(row).to have_selector(".enabled-job")
            expect(row).to have_selector(".glyphicon-ok")
          end
        end

        context "job is disabled" do
          before(:each) { job.update(enabled: false) }

          it "displays the disabled icon with CSS status" do
            render

            field_label =
              Clockface::ClockworkScheduledJob.human_attribute_name("enabled")

            row = page.find(".jobs-delete__job-detail-element--enabled")

            expect(row.find("label")).to have_content(field_label)
            expect(row).to have_selector(".disabled-job")
            expect(row).to have_selector(".glyphicon-remove")
          end
        end
      end

      describe "tenant field" do
        before(:each) { job.update(tenant: nil) }

        it "doesn't display the tenant field" do
          render

          expect(page).
            to_not have_selector(".jobs-delete__job-detail-element--tenant")
        end

        context "multi tenancy is enabled" do
          before(:each) do
            Clockface::Engine.config.clockface.tenant_list = %w(foo)
            job.update(tenant: "foo")
          end

          it "displays the tenant field" do
            render

            field_label =
              Clockface::ClockworkScheduledJob.human_attribute_name("tenant")
            row = page.find(".jobs-delete__job-detail-element--tenant")

            expect(row.find("label")).to have_content(field_label)
            expect(row).to have_content(job.tenant)
          end
        end
      end
    end

    it "displays the captcha label" do
      render
      expect(page.find(".jobs-delete__captcha-label")).to have_content(
        strip_tags(t("clockface.jobs.delete.captcha_label", captcha: captcha))
      )
    end

    describe "form" do
      it "displays the captch text input field" do
      end

      it "displays the submit button" do
      end

      it "displays the cancel button, linking back to jobs_path" do
      end
    end
  end
end
