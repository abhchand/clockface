require "rails_helper"

module Clockface
  RSpec.describe TasksController, type: :controller do
    routes { Clockface::Engine.routes }

    describe "GET #index" do
      it "assigns the ordered list of all tasks" do
        task1 = create(:task)
        task2 = create(:task)

        get :index

        expect(response.status).to eq(200)
        expect(response).to render_template("tasks/index")

        tasks = assigns(:tasks)
        expect(tasks).to eq([task1, task2])
      end
    end

    describe "GET #new" do
      it "returns 200 and renders the tasks/new template" do
        get :new

        expect(response.status).to eq(200)
        expect(response).to render_template("tasks/new")
      end
    end

    describe "POST #create" do
      let(:params) do
        {
          task: {
            name: "my fun task",
            description: "testing n' stuff",
            command: "some command"
          }
        }
      end

      it "creates a new task and redirects to task/index" do
        expect do
          post :create, params: params
        end.to change { Clockface::Task.count }.by(1)

        task = Clockface::Task.last

        expect(task.name).to eq("my fun task")
        expect(task.description).to eq("testing n' stuff")
        expect(task.command).to eq("some command")

        expect(flash[:success]).to eq(t("clockface.tasks.create.success"))

        expect(response).to redirect_to(tasks_path)
      end

      context "task fails validation" do
        before { params[:task][:name] = "" }

        it "doesn't create a new task and redirects to the new_task_path" do
          expect do
            post :create, params: params
          end.to change { Clockface::Task.count }.by(0)

          attribute = Clockface::Task.human_attribute_name("name")
          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/task."\
                "attributes.name.blank",
                attribute: attribute
              )
            ]
          )

          expect(response).to redirect_to(new_task_path)
        end
      end
    end

    describe "GET #edit" do
      let(:task) { create(:task) }

      it "sets the task" do
        get :edit, params: { id: task.id }

        expect(assigns(:task)).to eq(task)

        expect(response.status).to eq(200)
        expect(response).to render_template("tasks/edit")
      end

      context "no task exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :edit, params: { id: task.id + 1 }
          expect(response).to redirect_to(tasks_path)
          expect(flash[:error]).
            to eq(t("clockface.tasks.edit.validation.invalid_id"))
        end
      end
    end

    describe "PATCH #update" do
      let(:task) { create(:task) }

      let(:task) do
        create(
          :task,
          name: "old task",
          description: "description for old task",
          command: "old command"
        )
      end

      let(:params) do
        # Make sure attributes are different from the existing task, to test
        # that the update works for each attribute
        {
          task: {
            name: "new task",
            description: "description for new task",
            command: "new command"
          }
        }
      end

      before do
        task
        params
      end

      it "updates the existing task and redirects to tasks/index" do
        expect do
          patch :update, params: params.merge(id: task.id)
        end.to change { Clockface::Task.count }.by(0)

        task = Clockface::Task.last

        expect(task.name).to eq("new task")
        expect(task.description).to eq("description for new task")
        expect(task.command).to eq("new command")

        expect(flash[:success]).to eq(t("clockface.tasks.update.success"))

        expect(response).to redirect_to(tasks_path)
      end

      context "task fails validation" do
        before { params[:task][:name] = "" }

        it "doesn't update a new task and redirects to the edit_task_path" do
          expect_any_instance_of(Clockface::Task).to_not receive(:save)

          expect do
            patch :update, params: params.merge(id: task.id)
          end.to change { Clockface::Task.count }.by(0)

          attribute = Clockface::Task.human_attribute_name("name")
          expect(flash[:error]).to eq(
            [
              t(
                "activerecord.errors.models.clockface/task."\
                "attributes.name.blank",
                attribute: attribute
              )
            ]
          )

          expect(response).to redirect_to(edit_task_path(task))
        end
      end

      context "task with specified id does not exist" do
        it "sets the flash error message and redirects to the tasks_path" do
          patch :update, params: params.merge(id: task.id + 1)

          expect(flash[:error]).to eq(
            t("clockface.tasks.update.task_not_found", id: task.id + 1)
          )
          expect(response).to redirect_to(tasks_path)
        end
      end
    end

    describe "GET #delete" do
      let(:task) { create(:task) }

      it "sets the event and captcha and renders tasks/delete" do
        get :delete, params: { task_id: task.id }

        expect(response.status).to eq(200)
        expect(response).to render_template("tasks/delete")

        expect(assigns(:task)).to eq(task)

        captcha_length = Clockface::TasksController::CAPTCHA_LENGTH
        expect(assigns(:captcha)).
          to eq(Digest::SHA1.hexdigest(task.id.to_s).first(captcha_length))
      end

      context "no task exists with the specified id" do
        it "sets the flash error and redirects to the index page" do
          get :delete, params: { task_id: task.id + 1 }
          expect(response).to redirect_to(tasks_path)
          expect(flash[:error]).
            to eq(t("clockface.tasks.delete.validation.invalid_id"))
        end
      end
    end

    describe "DELETE destroy" do
      let(:task) { create(:task) }
      let(:captcha) { @controller.send(:captcha_for, task) }

      before { task }

      it "destroys the existing task and redirects to tasks/index" do
        expect do
          patch :destroy, params: { id: task.id, captcha: captcha }
        end.to change { Clockface::Task.count }.by(-1)

        expect(flash[:success]).to eq(t("clockface.tasks.destroy.success"))
        expect(response).to redirect_to(tasks_path)
      end

      context "task with specified id does not exist" do
        it "doesn't destroy the task and redirects to the tasks_path" do
          expect do
            patch :destroy, params: { id: task.id + 1, captcha: captcha }
          end.to change { Clockface::Task.count }.by(0)

          expect(flash[:error]).to eq(
            t("clockface.tasks.destroy.task_not_found", id: task.id + 1)
          )
          expect(response).to redirect_to(tasks_path)
        end
      end

      context "task fails validation" do
        context "captcha is incorrect" do
          let(:captcha) { "bad captcha" }

          it "doesn't destroy the task and redirects to tasks/delete" do
            expect do
              patch :destroy, params: { id: task.id, captcha: captcha }
            end.to change { Clockface::Task.count }.by(0)

            expect(flash[:error]).
              to eq(t("clockface.tasks.destroy.validation.incorrect_captcha"))
            expect(response).to redirect_to(task_delete_path(task))
          end
        end
      end

      context "task has events" do
        before { create(:event, task: task) }

        it "doesn't destroy the task and redirects to tasks/delete" do
          expect do
            patch :destroy, params: { id: task.id, captcha: captcha }
          end.to change { Clockface::Task.count }.by(0)

          expect(flash[:error]).
            to eq(
              t("clockface.tasks.destroy.validation.events_exist", count: 1)
            )
          expect(response).to redirect_to(task_delete_path(task))
        end
      end

      context "destroying the model is unsuccessful" do
        before do
          allow_any_instance_of(Clockface::Task).to receive(:destroy) { false }
        end

        it "doesn't destroy the task and redirects to tasks/delete" do
          expect do
            patch :destroy, params: { id: task.id, captcha: captcha }
          end.to change { Clockface::Task.count }.by(0)

          expect(flash[:error]).to eq(t("clockface.tasks.destroy.failure"))
          expect(response).to redirect_to(task_delete_path(task))
        end
      end
    end
  end
end
