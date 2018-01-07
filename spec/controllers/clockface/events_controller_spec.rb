require "rails_helper"

module Clockface
  RSpec.describe EventsController, type: :controller do
    routes { Clockface::Engine.routes }

    describe "GET #index" do
      it "returns 200 and renders the events/index template" do
        get :index

        expect(response.status).to eq(200)
        expect(response).to render_template("events/index")
      end

      it "assigns the ordered list of all events, wrapped in a presenter" do
        event1 = create(:event)
        event2 = create(:event)

        get :index

        events = assigns(:events)

        expect(events.length).to eq(2)

        expect(events.first).to be_an_instance_of(Clockface::EventsPresenter)
        expect(events.last).to be_an_instance_of(Clockface::EventsPresenter)

        expect(events.first.__getobj__).to eq(event1)
        expect(events.last.__getobj__).to eq(event2)
      end
    end

    describe "GET #new" do
      it "returns 200 and renders the events/new template" do
        get :new

        expect(response.status).to eq(200)
        expect(response).to render_template("events/new")
      end
    end

    describe "POST #create" do
      let(:task) { create(:task) }

      let(:params) do
        {
          event: {
            clockface_task_id: task.id,
            enabled: "1",
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

      it "creates a new event" do
        expect do
          post :create, params: params
        end.to change { Clockface::Event.count }.by(1)

        event = Clockface::Event.last

        expect(event.clockface_task_id).to eq(task.id)
        expect(event.enabled).to be_truthy
        expect(event.tenant).to be_nil
        expect(event.period_value).to eq(7)
        expect(event.period_units).to eq("minutes")
        expect(event.day_of_week).to eq(0)
        expect(event.hour).to be_nil
        expect(event.minute).to eq(12)
        expect(event.time_zone).to eq("Alaska")
        expect(event.if_condition).to eq("even_week")
      end

      it "sets the flash success message" do
        post :create, params: params

        expect(flash[:success]).
          to eq(t("clockface.events.create.success"))
      end

      it "redirects to the events/index path" do
        post :create, params: params

        expect(response).to redirect_to(events_path)
      end

      context "multi tenancy is enabled" do
        before { enable_multi_tenancy! }

        it "creates a new event with the specified tenant" do
          expect do
            post :create, params: params
          end.to change { Clockface::Event.count }.by(1)

          event = Clockface::Event.last
          expect(event.task).to eq(task)
          expect(event.tenant).to eq(tenant)
        end
      end

      context "event fails validation" do
        before { params[:event][:hour] = "-1" }

        it "doesn't create a new event" do
          expect do
            post :create, params: params
          end.to change { Clockface::Event.count }.by(0)
        end

        it "sets the flash error message" do
          post :create, params: params

          attribute =
            Clockface::Event.human_attribute_name("hour")

          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/event."\
                "attributes.hour.inclusion",
                attribute: attribute
              )
            ]
          )
        end

        it "redirects back to the new_event_path" do
          post :create, params: params

        expect(response).to redirect_to(new_event_path)
        end
      end
    end

    describe "GET #edit" do
      let(:event) { create(:event) }

      it "returns 200 and renders the events/edit template" do
        get :edit, params: { id: event.id }

        expect(response.status).to eq(200)
        expect(response).to render_template("events/edit")
      end

      it "sets the event" do
        get :edit, params: { id: event.id }

        expect(assigns(:event)).to eq(event)
      end

      context "no event exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :edit, params: { id: event.id + 1 }
          expect(response).to redirect_to(events_path)
          expect(flash[:error]).
            to eq(t("clockface.events.edit.validation.invalid_id"))
        end
      end
    end

    describe "PATCH #update" do
      let(:task) { create(:task) }

      let(:event) do
        create(
          :event,
          task: task,
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
        # Make sure attributes are different from the existing event, to test
        # that the update works for each attribute
        {
          event: {
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

      before do
        event
        params
      end

      it "updates the existing event" do
        expect do
          patch :update, params: params.merge(id: event.id)
        end.to change { Clockface::Event.count }.by(0)

        event = Clockface::Event.last

        # Task is not update-able. Validate it hasn't changed
        expect(event.clockface_task_id).to eq(task.id)

        expect(event.enabled).to be_truthy
        expect(event.period_value).to eq(20)
        expect(event.period_units).to eq("hours")
        expect(event.day_of_week).to eq(5)
        expect(event.hour).to be_nil
        expect(event.minute).to eq(12)
        expect(event.time_zone).to eq("Alaska")
        expect(event.if_condition).to eq("even_week")
      end

      it "sets the flash success message" do
        patch :update, params: params.merge(id: event.id)

        expect(flash[:success]).
          to eq(t("clockface.events.update.success"))
      end

      it "redirects to the events/index path" do
        patch :update, params: params.merge(id: event.id)

        expect(response).to redirect_to(events_path)
      end

      context "event fails validation" do
        before { params[:event][:hour] = "-1" }

        it "doesn't update a new event" do
          expect_any_instance_of(Clockface::Event).
            to_not receive(:save)

          expect do
            patch :update, params: params.merge(id: event.id)
          end.to change { Clockface::Event.count }.by(0)

          # Pick one field to test - task should be unchanged
          event = Clockface::Event.last
          expect(event.clockface_task_id).to eq(task.id)
        end

        it "sets the flash error message" do
          patch :update, params: params.merge(id: event.id)

          attribute =
            Clockface::Event.human_attribute_name("hour")

          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/event."\
                "attributes.hour.inclusion",
                attribute: attribute
              )
            ]
          )
        end

        it "redirects back to the edit_event_path" do
          patch :update, params: params.merge(id: event.id)

          expect(response).to redirect_to(edit_event_path(event))
        end
      end

      context "event with specified id does not exist" do
        it "sets the flash error message" do
          patch :update, params: params.merge(id: event.id + 1)

          expect(flash[:error]).to eq(
            t("clockface.events.update.event_not_found", id: event.id + 1)
          )
        end

        it "redirects to the events_path" do
          patch :update, params: params.merge(id: event.id + 1)

          expect(response).to redirect_to(events_path)
        end
      end
    end

    describe "GET #delete" do
      let(:event) { create(:event) }

      it "returns 200 and renders the events/delete template" do
        get :delete, params: { event_id: event.id }

        expect(response.status).to eq(200)
        expect(response).to render_template("events/delete")
      end

      it "sets the event" do
        get :delete, params: { event_id: event.id }

        expect(assigns(:event)).to be_an_instance_of(Clockface::EventsPresenter)
        expect(assigns(:event).__getobj__).to eq(event)
      end

      it "sets the captcha as the first few charactes of the id's SHA-1" do
        captcha_length = Clockface::EventsController::CAPTCHA_LENGTH

        get :delete, params: { event_id: event.id }

        expect(assigns(:captcha)).
          to eq(Digest::SHA1.hexdigest(event.id.to_s).first(captcha_length))
      end

      context "no event exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :delete, params: { event_id: event.id + 1 }
          expect(response).to redirect_to(events_path)
          expect(flash[:error]).
            to eq(t("clockface.events.delete.validation.invalid_id"))
        end
      end
    end

    describe "DELETE destroy" do
      let(:task) { create(:task) }
      let(:event) { create(:event) }
      let(:captcha) { @controller.send(:captcha_for, event) }

      before do
        task
        event
      end

      it "destroys the existing event" do
        expect do
          patch :destroy, params: { id: event.id, captcha: captcha }
        end.to change { Clockface::Event.count }.by(-1)
      end

      it "sets the flash success message" do
        patch :destroy, params: { id: event.id, captcha: captcha }

        expect(flash[:success]).to eq(t("clockface.events.destroy.success"))
      end

      it "redirects to the events/index path" do
        patch :destroy, params: { id: event.id, captcha: captcha }

        expect(response).to redirect_to(events_path)
      end

      context "event with specified id does not exist" do
        it "doesn't destroy the event" do
          expect do
            patch :destroy, params: { id: event.id + 1, captcha: captcha }
          end.to change { Clockface::Event.count }.by(0)
        end

        it "sets the flash error message" do
          patch :destroy, params: { id: event.id + 1, captcha: captcha }

          expect(flash[:error]).to eq(
            t("clockface.events.destroy.event_not_found", id: event.id + 1)
          )
        end

        it "redirects to the events_path" do
          patch :destroy, params: { id: event.id + 1, captcha: captcha }

          expect(response).to redirect_to(events_path)
        end
      end

      context "event fails validation" do
        context "captcha is incorrect" do
          let(:captcha) { "bad captcha" }

          it "doesn't destroy the event" do
            expect do
              patch :destroy, params: { id: event.id, captcha: captcha }
            end.to change { Clockface::Event.count }.by(0)
          end

          it "sets the flash error message" do
            patch :destroy, params: { id: event.id, captcha: captcha }

            expect(flash[:error]).
              to eq(t("clockface.events.destroy.validation.incorrect_captcha"))
          end

          it "redirects to the events/delete path" do
            patch :destroy, params: { id: event.id, captcha: captcha }

            expect(response).to redirect_to(event_delete_path(event))
          end
        end
      end

      context "destroying the model is unsuccessful" do
        before do
          allow_any_instance_of(Clockface::Event).
            to receive(:destroy) { false }
        end

        it "doesn't destroy the event" do
          expect do
            patch :destroy, params: { id: event.id, captcha: captcha }
          end.to change { Clockface::Event.count }.by(0)
        end

        it "sets the flash error message" do
          patch :destroy, params: { id: event.id, captcha: captcha }

          expect(flash[:error]).to eq(t("clockface.events.destroy.failure"))
        end

        it "redirects to the events/delete path" do
          patch :destroy, params: { id: event.id, captcha: captcha }

          expect(response).to redirect_to(event_delete_path(event))
        end
      end
    end
  end
end
