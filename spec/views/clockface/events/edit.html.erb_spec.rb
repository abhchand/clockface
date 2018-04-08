require "rails_helper"

module Clockface
  RSpec.describe "clockface/events/edit.html.erb", type: :view do
    let(:event) { create(:event) }

    before { assign(:event, event) }

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.events.edit.heading").downcase)
    end

    it "renders the back link" do
      render
      link = page.find(
        ".events-edit__heading-banner .events-edit__heading-banner-link"
      )

      expect(link["href"]).to eq(clockface.events_path)
      expect(link).to have_selector(".glyphicon-chevron-left")
    end

    it "renders the events form" do
      render
      expect(view).to render_template(partial: "_event_form")
    end
  end
end
