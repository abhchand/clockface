require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/new.html.erb", type: :view do
    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.jobs.new.heading").downcase)
    end

    it "renders the back link" do
      render
      link = page.
        find(".jobs-new__heading-banner .jobs-new__heading-banner-link")

      expect(link["href"]).to eq(clockface.jobs_path)
      expect(link).to have_selector(".glyphicon-chevron-left")
    end

    it "renders the jobs form" do
      render
      expect(view).to render_template(partial: "_job_form")
    end
  end
end
