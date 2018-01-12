module Clockface
  class TasksController < ApplicationController
    def index
      @tasks = all_tasks
    end

    def new
    end

    def create
      task = Clockface::Task.new(tasks_params_for_create)
      validation = validate_task(task)

      if validation.failure?
        flash[:error] = validation.errors
        redirect_to clockface.new_task_path
        return
      end

      task.save
      flash[:success] = t("clockface.tasks.create.success")
      clockface_log(:info, "Created Task: #{task.inspect}")
      redirect_to clockface.tasks_path
    end

    def edit
      @task = Clockface::Task.find_by_id(params[:id])

      unless @task
        redirect_to tasks_path
        flash[:error] = t("clockface.tasks.edit.validation.invalid_id")
      end
    end

    def update
      task = Clockface::Task.find_by_id(params[:id])

      unless task
        flash[:error] =
          t("clockface.tasks.update.task_not_found", id: params[:id])
        redirect_to tasks_path
        return
      end

      task.attributes = tasks_params_for_update
      validation = validate_task(task)

      if validation.success?
        task.save
        flash[:success] = t("clockface.tasks.update.success")
        clockface_log(:info, "Updated Task: #{task.inspect}")
        redirect_to clockface.tasks_path
      else
        flash[:error] = validation.errors
        redirect_to clockface.edit_task_path(task)
      end
    end

    def delete
      @task = Clockface::Task.find_by_id(params[:task_id])

      unless @task
        redirect_to tasks_path
        flash[:error] = t("clockface.tasks.delete.validation.invalid_id")
        return
      end

      @captcha = captcha_for(@task)
    end

    def destroy
      task = Clockface::Task.find_by_id(params[:id])

      unless task
        flash[:error] =
          t("clockface.tasks.destroy.task_not_found", id: params[:id])
        redirect_to tasks_path
        return
      end

      # TODO: Move this to interactor

      if (params[:captcha] || "") != captcha_for(task)
        flash[:error] =
          t("clockface.tasks.destroy.validation.incorrect_captcha")
        redirect_to task_delete_path(task)
        return
      end

      if task.events.any?
        flash[:error] =
          t(
            "clockface.tasks.destroy.validation.events_exist",
            count: task.events.count
          )
        redirect_to task_delete_path(task)
        return
      end

      unless task.destroy
        flash[:error] = t("clockface.tasks.destroy.failure")
        redirect_to task_delete_path(task)
        return
      end

      flash[:success] = t("clockface.tasks.destroy.success")
      clockface_log(:info, "Destroyed Task: #{task.inspect}")
      redirect_to tasks_path
    end

    private

    def all_tasks
      Clockface::Task.includes(:events).order(:id)
    end

    def tasks_params_for_create
      params.require(:task).permit(
        :name,
        :description,
        :command
      )
    end

    def tasks_params_for_update
      params.require(:task).permit(
        :name,
        :description,
        :command
      )
    end

    def validate_task(task)
      Clockface::TaskValidationInteractor.
        call(task: task, action: params[:action])
    end
  end
end
