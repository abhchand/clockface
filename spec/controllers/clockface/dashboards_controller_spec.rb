require "rails_helper"

module Clockface
  RSpec.describe DashboardsController, type: :controller do
    routes { Clockface::Engine.routes }

    describe "GET #show" do
      it "returns 200 and renders the dashboard/show template" do
        get :show

        expect(response.status).to eq(200)
        expect(response).to render_template("dashboards/show")
      end

      it "assigns the list of all scheduled jobs" do
        job1 = create(:clockwork_scheduled_job)
        job2 = create(:clockwork_scheduled_job)

        get :show

        expect(assigns(:scheduled_jobs)).to match_array([job1, job2])
      end
    end
  end
end
