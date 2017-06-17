require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/edit.html.erb", type: :view do
    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.jobs.edit.heading"))
    end

    it "renders the jobs form" do
      render
      expect(view).to render_template(partial: "_job_form")
    end
  end
end
