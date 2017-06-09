require "rails_helper"

module Clockface
  RSpec.describe Clockface::DashboardsController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes GET '/' to dashboards#show" do
      expect(get: "/").
        to route_to(controller: "clockface/dashboards", action: "show")
    end

    it "routes GET '/dashboard' to dashboards#show" do
      expect(get: "/dashboard").
        to route_to(controller: "clockface/dashboards", action: "show")
    end
  end
end
