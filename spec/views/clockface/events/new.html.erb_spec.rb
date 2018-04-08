require "rails_helper"

module Clockface
  RSpec.describe "clockface/events/new.html.erb", type: :view do
    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.events.new.heading").downcase)
    end

    it "renders the back link" do
      render
      link = page.find(
        ".events-new__heading-banner .events-new__heading-banner-link"
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
