require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/index.html.erb", type: :view do
    let(:job) { create(:clockwork_scheduled_job) }

    before(:each) do
      job
      assign(:jobs, Clockface::ClockworkScheduledJob.all)
    end

    it "renders the header" do
      render
      expect(page.find(".jobs-header__container")).to have_content(
        t("clockface.jobs.header.heading")
      )
    end

    it "displays the field headings" do
      render

      %w(id name period at timezone if_condition).each do |attribute|
        label = Clockface::ClockworkScheduledJob.human_attribute_name(attribute)
        css_id = "thead .jobs-index__jobs-column--#{attribute}"

        expect(page.find(css_id)).to have_content(label)
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

        # Only `if_condition` is not populated by the factory, so set it
        job.update(if_condition: "odd_week")


        # Run a sanity check to make sure every field is not nil, should the
        # factory ever change in the future
        %w(
          period_value
          period_units
          day_of_week
          hour
          minute
          timezone
          if_condition
        ).each do |attr|
          raise "#{attr} can not be nil!" if job.send(attr).blank?
        end
      end

      it_behaves_like "displayed job field", :id
      it_behaves_like "displayed job field", :name
      it_behaves_like "displayed job field", :period
      it_behaves_like "displayed job field", :at
      it_behaves_like "displayed job field", :timezone
      it_behaves_like "displayed job field", :if_condition
    end
  end
end