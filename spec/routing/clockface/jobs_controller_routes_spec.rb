require "rails_helper"

module Clockface
  RSpec.describe Clockface::JobsController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes GET '/jobs' to jobs#index" do
      expect(get: "/jobs").
        to route_to(controller: "clockface/jobs", action: "index")
    end

    it "routes GET '/jobs/new' to jobs#new" do
      expect(get: "/jobs/new").
        to route_to(controller: "clockface/jobs", action: "new")
    end

    it "routes POST '/jobs' to jobs#create" do
      expect(post: "/jobs").
        to route_to(controller: "clockface/jobs", action: "create")
    end

    it "routes GET '/jobs/1' to jobs#show" do
      expect(get: "/jobs/1").to route_to(
        controller: "clockface/jobs",
        action: "show",
        id: "1"
      )
    end

    it "routes GET '/jobs/1/edit' to jobs#edit" do
      expect(get: "/jobs/1/edit").to route_to(
        controller: "clockface/jobs",
        action: "edit",
        id: "1"
      )
    end

    it "routes PATCH '/jobs/1' to jobs#update" do
      expect(patch: "/jobs/1").to route_to(
        controller: "clockface/jobs",
        action: "update",
        id: "1"
      )
    end

    it "routes DELETE '/jobs/1' to jobs#destroy" do
      expect(delete: "/jobs/1").to route_to(
        controller: "clockface/jobs",
        action: "destroy",
        id: "1"
      )
    end
  end
end
