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

      it "sets the time_zone_selector_default to the clockface_time_zone" do
        allow(controller).to receive(:clockface_time_zone) { "Alaska" }

        get :new

        expect(assigns(:time_zone_selector_default)).to eq("Alaska")
      end
    end

    describe "POST #create" do
      let(:event) { create(:clockwork_event) }

      let(:params) do
        {
          clockwork_scheduled_job: {
            clockface_clockwork_event_id: event.id,
            enabled: "1",
            tenant: "foo",
            period_value: "7",
            period_units: "minutes",
            day_of_week: "0",
            hour: "**",
            minute: "12",
            time_zone: "Alaska",
            if_condition: "even_week"
          }
        }
      end

      it "creates a new job" do
        expect do
          post :create, params: params
        end.to change { Clockface::ClockworkScheduledJob.count }.by(1)

        job = Clockface::ClockworkScheduledJob.last

        expect(job.clockface_clockwork_event_id).to eq(event.id)
        expect(job.enabled).to be_truthy
        expect(job.tenant).to be_nil
        expect(job.period_value).to eq(7)
        expect(job.period_units).to eq("minutes")
        expect(job.day_of_week).to eq(0)
        expect(job.hour).to be_nil
        expect(job.minute).to eq(12)
        expect(job.time_zone).to eq("Alaska")
        expect(job.if_condition).to eq("even_week")
      end

      it "sets the flash success message" do
        post :create, params: params

        expect(flash[:success]).
          to eq(t("clockface.jobs.create.success"))
      end

      it "redirects to the jobs/index path" do
        post :create, params: params

        expect(response).to redirect_to(jobs_path)
      end

      context "multi tenancy is enabled" do
        before(:each) do
          Clockface::Engine.config.clockface.tenant_list = %w(foo)
        end

        it "creates a new job with the specified tenant" do
          expect do
            post :create, params: params
          end.to change { Clockface::ClockworkScheduledJob.count }.by(1)

          job = Clockface::ClockworkScheduledJob.last

          expect(job.clockface_clockwork_event_id).to eq(event.id)
          expect(job.tenant).to eq("foo")
        end
      end

      context "job fails validation" do
        before(:each) { params[:clockwork_scheduled_job][:hour] = "-1" }

        it "doesn't create a new job" do
          expect do
            post :create, params: params
          end.to change { Clockface::ClockworkScheduledJob.count }.by(0)
        end

        it "sets the flash error message" do
          post :create, params: params

          attribute =
            Clockface::ClockworkScheduledJob.human_attribute_name("hour")

          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/clockwork_scheduled_job."\
                "attributes.hour.inclusion",
                attribute: attribute
              )
            ]
          )
        end

        it "redirects back to the new_job_path" do
          post :create, params: params

        expect(response).to redirect_to(new_job_path)
        end
      end
    end

    describe "GET #edit" do
      let(:job) { create(:clockwork_scheduled_job) }

      it "returns 200 and renders the jobs/edit template" do
        get :edit, params: { id: job.id }

        expect(response.status).to eq(200)
        expect(response).to render_template("jobs/edit")
      end

      it "sets the job" do
        get :edit, params: { id: job.id }

        expect(assigns(:job)).to eq(job)
      end

      context "no job exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :edit, params: { id: job.id + 1 }
          expect(response).to redirect_to(jobs_path)
          expect(flash[:error]).
            to eq(t("clockface.jobs.edit.validation.invalid_id"))
        end
      end
    end

    describe "PATCH #update" do
      let(:event) { create(:clockwork_event) }

      let(:job) do
        create(
          :clockwork_scheduled_job,
          event: event,
          enabled: false,
          period_value: 10,
          period_units: "minutes",
          day_of_week: 0,
          hour: 1,
          minute: 3,
          time_zone: "UTC",
          if_condition: "odd_week"
        )
      end

      let(:params) do
        # Make sure attributes are different from the existing job, to test
        # that the update works for each attribute
        {
          clockwork_scheduled_job: {
            enabled: "1",
            period_value: "20",
            period_units: "hours",
            day_of_week: "5",
            hour: "**",
            minute: "12",
            time_zone: "Alaska",
            if_condition: "even_week"
          }
        }
      end

      before(:each) do
        job
        params
      end

      it "updates the existing job" do
        expect do
          patch :update, params: params.merge(id: job.id)
        end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

        job = Clockface::ClockworkScheduledJob.last

        # Event is not update-able. Validate it hasn't changed
        expect(job.clockface_clockwork_event_id).to eq(event.id)

        expect(job.enabled).to be_truthy
        expect(job.period_value).to eq(20)
        expect(job.period_units).to eq("hours")
        expect(job.day_of_week).to eq(5)
        expect(job.hour).to be_nil
        expect(job.minute).to eq(12)
        expect(job.time_zone).to eq("Alaska")
        expect(job.if_condition).to eq("even_week")
      end

      it "sets the flash success message" do
        patch :update, params: params.merge(id: job.id)

        expect(flash[:success]).
          to eq(t("clockface.jobs.update.success"))
      end

      it "redirects to the jobs/index path" do
        patch :update, params: params.merge(id: job.id)

        expect(response).to redirect_to(jobs_path)
      end

      context "job fails validation" do
        before(:each) { params[:clockwork_scheduled_job][:hour] = "-1" }

        it "doesn't update a new job" do
          expect_any_instance_of(Clockface::ClockworkScheduledJob).
            to_not receive(:save)

          expect do
            patch :update, params: params.merge(id: job.id)
          end.to change { Clockface::ClockworkScheduledJob.count }.by(0)

          # Pick one field to test - event should be unchanged
          job = Clockface::ClockworkScheduledJob.last
          expect(job.clockface_clockwork_event_id).to eq(event.id)
        end

        it "sets the flash error message" do
          patch :update, params: params.merge(id: job.id)

          attribute =
            Clockface::ClockworkScheduledJob.human_attribute_name("hour")

          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/clockwork_scheduled_job."\
                "attributes.hour.inclusion",
                attribute: attribute
              )
            ]
          )
        end

        it "redirects back to the edit_job_path" do
          patch :update, params: params.merge(id: job.id)

          expect(response).to redirect_to(edit_job_path(job))
        end
      end

      context "job with specified id does not exist" do
        it "sets the flash error message" do
          patch :update, params: params.merge(id: job.id + 1)

          expect(flash[:error]).to eq(
            t("clockface.jobs.update.job_not_found", id: job.id + 1)
          )
        end

        it "redirects to the jobs_path" do
          patch :update, params: params.merge(id: job.id + 1)

          expect(response).to redirect_to(jobs_path)
        end
      end
    end

    describe "GET #delete" do
      let(:job) { create(:clockwork_scheduled_job) }

      it "returns 200 and renders the jobs/delete template" do
        get :delete, params: { job_id: job.id }

        expect(response.status).to eq(200)
        expect(response).to render_template("jobs/delete")
      end

      it "sets the job" do
        get :delete, params: { job_id: job.id }

        expect(assigns(:job)).to be_an_instance_of(Clockface::JobsPresenter)
        expect(assigns(:job).__getobj__).to eq(job)
      end

      it "sets the captcha as the first few charactes of the id's SHA-1" do
        captcha_length = Clockface::JobsController::CAPTCHA_LENGTH

        get :delete, params: { job_id: job.id }

        expect(assigns(:captcha)).
          to eq(Digest::SHA1.hexdigest(job.id.to_s).first(captcha_length))
      end

      context "no job exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :delete, params: { job_id: job.id + 1 }
          expect(response).to redirect_to(jobs_path)
          expect(flash[:error]).
            to eq(t("clockface.jobs.delete.validation.invalid_id"))
        end
      end
    end

    describe "DELETE destroy" do
      let(:event) { create(:clockwork_event) }
      let(:job) { create(:clockwork_scheduled_job) }
      let(:captcha) { @controller.send(:captcha_for, job) }

      before(:each) do
        event
        job
      end

      it "destroys the existing job" do
        expect do
          patch :destroy, params: { id: job.id, captcha: captcha }
        end.to change { Clockface::ClockworkScheduledJob.count }.by(-1)
      end

      it "sets the flash success message" do
        patch :destroy, params: { id: job.id, captcha: captcha }

        expect(flash[:success]).to eq(t("clockface.jobs.destroy.success"))
      end

      it "redirects to the jobs/index path" do
        patch :destroy, params: { id: job.id, captcha: captcha }

        expect(response).to redirect_to(jobs_path)
      end

      context "job with specified id does not exist" do
        it "doesn't destroy the job" do
          expect do
            patch :destroy, params: { id: job.id + 1, captcha: captcha }
          end.to change { Clockface::ClockworkScheduledJob.count }.by(0)
        end

        it "sets the flash error message" do
          patch :destroy, params: { id: job.id + 1, captcha: captcha }

          expect(flash[:error]).to eq(
            t("clockface.jobs.destroy.job_not_found", id: job.id + 1)
          )
        end

        it "redirects to the jobs_path" do
          patch :destroy, params: { id: job.id + 1, captcha: captcha }

          expect(response).to redirect_to(jobs_path)
        end
      end

      context "job fails validation" do
        context "captcha is incorrect" do
          let(:captcha) { "bad captcha" }

          it "doesn't destroy the job" do
            expect do
              patch :destroy, params: { id: job.id, captcha: captcha }
            end.to change { Clockface::ClockworkScheduledJob.count }.by(0)
          end

          it "sets the flash error message" do
            patch :destroy, params: { id: job.id, captcha: captcha }

            expect(flash[:error]).
              to eq(t("clockface.jobs.destroy.validation.incorrect_captcha"))
          end

          it "redirects to the jobs/delete path" do
            patch :destroy, params: { id: job.id, captcha: captcha }

            expect(response).to redirect_to(job_delete_path(job))
          end
        end
      end

      context "destroying the model is unsuccessful" do
        before(:each) do
          allow_any_instance_of(Clockface::ClockworkScheduledJob).
            to receive(:destroy) { false }
        end

        it "doesn't destroy the job" do
          expect do
            patch :destroy, params: { id: job.id, captcha: captcha }
          end.to change { Clockface::ClockworkScheduledJob.count }.by(0)
        end

        it "sets the flash error message" do
          patch :destroy, params: { id: job.id, captcha: captcha }

          expect(flash[:error]).to eq(t("clockface.jobs.destroy.failure"))
        end

        it "redirects to the jobs/delete path" do
          patch :destroy, params: { id: job.id, captcha: captcha }

          expect(response).to redirect_to(job_delete_path(job))
        end
      end
    end
  end
end
