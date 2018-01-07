require "rails_helper"

module Clockface
  RSpec.describe Clockface::TasksController, type: :routing do
    routes { Clockface::Engine.routes }

    it "routes GET '/tasks' to tasks#index" do
      expect(get: "/tasks").
        to route_to(controller: "clockface/tasks", action: "index")
    end

    it "routes GET '/tasks/new' to tasks#new" do
      expect(get: "/tasks/new").
        to route_to(controller: "clockface/tasks", action: "new")
    end

    it "routes POST '/tasks' to tasks#create" do
      expect(post: "/tasks").
        to route_to(controller: "clockface/tasks", action: "create")
    end

    it "routes GET '/tasks/1/edit' to tasks#edit" do
      expect(get: "/tasks/1/edit").to route_to(
        controller: "clockface/tasks",
        action: "edit",
        id: "1"
      )
    end

    it "routes PATCH '/tasks/1' to tasks#update" do
      expect(patch: "/tasks/1").to route_to(
        controller: "clockface/tasks",
        action: "update",
        id: "1"
      )
    end

    it "routes GET '/tasks/1/delete' to tasks#delete" do
      expect(get: "/tasks/1/delete").to route_to(
        controller: "clockface/tasks",
        action: "delete",
        task_id: "1"
      )
    end

    it "routes DELETE '/tasks/1' to tasks#destroy" do
      expect(delete: "/tasks/1").to route_to(
        controller: "clockface/tasks",
        action: "destroy",
        id: "1"
      )
    end
  end
end
