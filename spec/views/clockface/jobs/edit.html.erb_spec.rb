require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/edit.html.erb", type: :view do
    let(:job) { create(:clockwork_scheduled_job) }

    before(:each) { assign(:job, job) }

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.jobs.edit.heading").downcase)
    end

    it "renders the back link" do
      render
      link = page.
        find(".jobs-edit__heading-banner .jobs-edit__heading-banner-link")

      expect(link["href"]).to eq(clockface.jobs_path)
      expect(link).to have_selector(".glyphicon-chevron-left")
    end

    it "renders the jobs form" do
      render
      expect(view).to render_template(partial: "_job_form")
    end
  end
end
