require "rails_helper"

module Clockface
  RSpec.describe "clockface/application/_nav.html.erb", type: :view do
    it "renders the app icon, name, and version" do
      render_partial

      header = page.find(".navbar-header")

      expect(header.find(".application-nav__icon")).to have_selector("svg")
      expect(header.find(".application-nav__heading")).
        to have_content(t("clockface.application.nav.heading"))
      expect(header.find(".application-nav__version")).
        to have_content("v" + Clockface::VERSION)
    end

    def render_partial(opts = {})
      render(partial: "clockface/application/nav")
    end
  end
end
