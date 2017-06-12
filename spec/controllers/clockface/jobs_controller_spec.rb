require "rails_helper"

module Clockface
  RSpec.describe JobsController, type: :controller do
    routes { Clockface::Engine.routes }

    describe "GET #index" do
      it "returns 200 and renders the jobs/index template" do
        get :index

        expect(response.status).to eq(200)
        expect(response).to render_template("jobs/index")
      end

      it "assigns the list of all scheduled jobs" do
        job1 = create(:clockwork_scheduled_job)
        job2 = create(:clockwork_scheduled_job)

        get :index

        expect(assigns(:jobs)).to match_array([job1, job2])
      end
    end
  end
end
