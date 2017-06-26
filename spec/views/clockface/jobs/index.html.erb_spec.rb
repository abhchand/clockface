require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/index.html.erb", type: :view do
    let(:job) { create(:clockwork_scheduled_job) }

    before(:each) do
      job
      assign(:jobs, Clockface::ClockworkScheduledJob.all)
      view.extend ClockfaceConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.jobs.index.heading").downcase)
    end

    it "displays a 'new' button" do
      render

      link = page.find(".jobs-index__new-link")
      button = link.find(".jobs-index__new-btn")

      expect(link["href"]).to eq(clockface.new_job_path)
      expect(button).to have_selector(".glyphicon-plus")
    end

    describe "field headings" do
      it "displays the field headings" do
        render

        columns =
          %w(id name period at time_zone if_condition last_run_at enabled)

        columns.each do |attribute|
          label = Clockface::ClockworkScheduledJob.human_attribute_name(attribute)
          css_id = "thead .jobs-index__jobs-column--#{attribute}"

          expect(page.find(css_id)).to have_content(label)
        end
      end

      describe "tenant" do
        it "does not display the tenant field heading" do
          render

          css_id = "thead .jobs-index__jobs-column--tenant"
          expect(page).to_not have_selector(css_id)
        end

        context "multi tenancy is enabled" do
          before(:each) do
            Clockface::Engine.config.clockface.tenant_list = %w(foo)
            job.update(tenant: "foo")
          end

          it "does not display the tenant field heading" do
            render

            label = Clockface::ClockworkScheduledJob.human_attribute_name("tenant")
            css_id = "thead .jobs-index__jobs-column--tenant"

            expect(page.find(css_id)).to have_content(label)
          end
        end
      end
    end

    it "displays a row for each job" do
      job1 = job
      job2 = create(:clockwork_scheduled_job)
      assign(:jobs, Clockface::ClockworkScheduledJob.all)

      render

      [job1, job2].each do |job|
        expect(page).
          to have_selector("tr.jobs-index__jobs-row[data-id='#{job.id}']")
      end
    end

    describe "job row" do
      shared_examples "displayed job field" do |field_name|
        it "displays the field_value" do
          render

          field_value = job.send(field_name)

          table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
          field = table_row.find(".jobs-index__jobs-column--#{field_name}")

          expect(field).to have_content(field_value)
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

            table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
            field = table_row.find(".jobs-index__jobs-column--enabled")

            expect(field).to have_selector(".enabled-job")
            expect(field).to have_selector(".glyphicon-ok")
          end
        end

        context "job is disabled" do
          before(:each) { job.update(enabled: false) }

          it "displays the disabled icon with CSS status" do
            render

            table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
            field = table_row.find(".jobs-index__jobs-column--enabled")

            expect(field).to have_selector(".disabled-job")
            expect(field).to have_selector(".glyphicon-remove")
          end
        end
      end

      describe "tenant field" do
        before(:each) { job.update(tenant: nil) }

        it "doesn't display the tenant field" do
          render

          table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
          expect(table_row).to_not have_selector("jobs-index__jobs-column--tenant")
        end

        context "multi tenancy is enabled" do
          before(:each) do
            Clockface::Engine.config.clockface.tenant_list = %w(foo)
            job.update(tenant: "foo")
          end

          it "displays the tenant field" do
            render

            table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
            field = table_row.find(".jobs-index__jobs-column--tenant")

            expect(field).to have_content(job.tenant)
          end
        end
      end

      it "displays a link to edit the job" do
        render

        table_row = page.find("tr.jobs-index__jobs-row[data-id='#{job.id}']")
        field = table_row.find(".jobs-index__jobs-column--edit")

        expect(field).
          to have_selector("a[href='#{clockface.edit_job_path(job)}']")
      end
    end
  end
end
