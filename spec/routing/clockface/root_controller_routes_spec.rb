require "rails_helper"

module Clockface
  RSpec.describe Clockface::RootController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes GET '/' to root#index" do
      expect(get: "/").
        to route_to(controller: "clockface/root", action: "index")
    end
  end
end
