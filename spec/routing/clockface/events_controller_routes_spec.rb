require "rails_helper"

module Clockface
  RSpec.describe Clockface::EventsController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes GET '/events' to events#index" do
      expect(get: "/events").
        to route_to(controller: "clockface/events", action: "index")
    end

    it "routes GET '/events/new' to events#new" do
      expect(get: "/events/new").
        to route_to(controller: "clockface/events", action: "new")
    end

    it "routes POST '/events' to events#create" do
      expect(post: "/events").
        to route_to(controller: "clockface/events", action: "create")
    end

    it "routes GET '/events/1/edit' to events#edit" do
      expect(get: "/events/1/edit").to route_to(
        controller: "clockface/events",
        action: "edit",
        id: "1"
      )
    end

    it "routes PATCH '/events/1' to events#update" do
      expect(patch: "/events/1").to route_to(
        controller: "clockface/events",
        action: "update",
        id: "1"
      )
    end

    it "routes GET '/events/1/delete' to events#delete" do
      expect(get: "/events/1/delete").to route_to(
        controller: "clockface/events",
        action: "delete",
        event_id: "1"
      )
    end

    it "routes DELETE '/events/1' to events#destroy" do
      expect(delete: "/events/1").to route_to(
        controller: "clockface/events",
        action: "destroy",
        id: "1"
      )
    end
  end
end
