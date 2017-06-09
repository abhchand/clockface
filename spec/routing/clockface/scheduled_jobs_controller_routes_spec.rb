require "rails_helper"

module Clockface
  RSpec.describe Clockface::ScheduledJobsController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes POST '/scheduled_jobs' to scheduled_jobs#create" do
      expect(post: "/scheduled_jobs").
        to route_to(controller: "clockface/scheduled_jobs", action: "create")
    end

    it "routes PATCH '/scheduled_jobs/1' to scheduled_jobs#update" do
      expect(patch: "/scheduled_jobs/1").to route_to(
        controller: "clockface/scheduled_jobs",
        action: "update",
        id: "1"
      )
    end

    it "routes DELETE '/scheduled_jobs/1' to scheduled_jobs#destroy" do
      expect(delete: "/scheduled_jobs/1").to route_to(
        controller: "clockface/scheduled_jobs",
        action: "destroy",
        id: "1"
      )
    end
  end
end
