require "rails_helper"

module Clockface
  RSpec.describe "clockface/tasks/edit.html.erb", type: :view do
    let(:task) { create(:task) }

    before { assign(:task, task) }

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.tasks.edit.heading").downcase)
    end

    it "renders the back link" do
      render
      link = page.
        find(".tasks-edit__heading-banner .tasks-edit__heading-banner-link")

      expect(link["href"]).to eq(clockface.tasks_path)
      expect(link).to have_selector(".glyphicon-chevron-left")
    end

    it "renders the tasks form" do
      render
      expect(view).to render_template(partial: "_task_form")
    end
  end
end
