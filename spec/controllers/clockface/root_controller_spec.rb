require "rails_helper"

module Clockface
  RSpec.describe RootController, type: :controller do
    routes { Clockface::Engine.routes }

    describe "GET #index" do
      it "should blindly redirect to the events path" do
        get :index
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
