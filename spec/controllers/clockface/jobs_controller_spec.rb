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

      it "assigns the ordered list of all jobs, wrapped in a presenter" do
        job1 = create(:clockwork_scheduled_job)
        job2 = create(:clockwork_scheduled_job)

        get :index

        jobs = assigns(:jobs)

        expect(jobs.length).to eq(2)

        expect(jobs.first).to be_an_instance_of(Clockface::JobsPresenter)
        expect(jobs.last).to be_an_instance_of(Clockface::JobsPresenter)

        expect(jobs.first.__getobj__).to eq(job1)
        expect(jobs.last.__getobj__).to eq(job2)
      end
    end

    describe "GET #new" do
      it "returns 200 and renders the jobs/new template" do
        get :new

        expect(response.status).to eq(200)
        expect(response).to render_template("jobs/new")
      end

      it "sets the default_timezone to the timezone of the last job" do
        job1 = create(:clockwork_scheduled_job, timezone: "UTC")
        job2 = create(:clockwork_scheduled_job, timezone: "Alaska")

        get :new

        expect(assigns(:default_timezone)).to eq("Alaska")
      end

      context "no last job exists" do
        it "falls back on UTC" do
          get :new

          expect(assigns(:default_timezone)).to eq("UTC")
        end
      end
    end
  end
end
