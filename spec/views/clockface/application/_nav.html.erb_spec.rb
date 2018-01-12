require "rails_helper"

module Clockface
  RSpec.describe "clockface/application/_nav.html.erb", type: :view do
    before { stub_params_controller("clockface/events") }

    it "renders the app icon, name, and version" do
      render_partial

      header = page.find(".navbar-header")

      expect(header.find(".application-nav__icon")).to have_selector("svg")
      expect(header.find(".application-nav__heading")).
        to have_content(t("clockface.application.nav.heading"))
    end

    it "renders the nav links" do
      render_partial

      links = page.find(".application-nav__link-container")

      expect(links.all(".application-nav__link").count).to eq(2)
      expect(links).
        to have_link(
          t(
            "clockface.application.nav.links.tasks",
            href: clockface.tasks_path
          )
        )
      expect(links).
        to have_link(
          t(
            "clockface.application.nav.links.events",
            href: clockface.events_path
          )
        )
    end

    [
      ["clockface/tasks", "application-nav__link application-nav__link--tasks"],
      ["clockface/events", "application-nav__link application-nav__link--events"]
    ].each do |(controller, css_class)|
      it "marks the selected nav link" do
        stub_params_controller(controller)

        render_partial

        link = page.find(".application-nav__link--selected")
        expect(link["class"]).to include(css_class)
      end
    end

    def render_partial(opts = {})
      render(partial: "clockface/application/nav")
    end

    def stub_params_controller(controller)
      allow(view).to receive(:params).and_return("controller" => controller)
    end
  end
end
