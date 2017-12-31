module Clockface
  class JobsController < ApplicationController
    CAPTCHA_LENGTH = 5

    def index
      @jobs = all_jobs.map { |job| Clockface::JobsPresenter.new(job) }
    end

    def new
    end

    def create
      job = Clockface::ClockworkScheduledJob.new(jobs_params_for_create)
      validation = validate_job(job)

      if validation.success?
        job.save
        flash[:success] = t("clockface.jobs.create.success")
        clockface_log(:info, "Created Job: #{job.inspect}")
        redirect_to clockface.jobs_path
      else
        flash[:error] = validation.errors
        redirect_to clockface.new_job_path
      end
    end

    def edit
      @job = Clockface::ClockworkScheduledJob.find_by_id(params[:id])

      unless @job
        redirect_to jobs_path
        flash[:error] = t("clockface.jobs.edit.validation.invalid_id")
      end
    end

    def update
      job = Clockface::ClockworkScheduledJob.find_by_id(params[:id])

      if !job
        flash[:error] =
          t("clockface.jobs.update.job_not_found", id: params[:id])
        redirect_to jobs_path
        return
      end

      job.attributes = jobs_params_for_update
      validation = validate_job(job)

      if validation.success?
        job.save
        flash[:success] = t("clockface.jobs.update.success")
        clockface_log(:info, "Updated Job: #{job.inspect}")
        redirect_to clockface.jobs_path
      else
        flash[:error] = validation.errors
        redirect_to clockface.edit_job_path(job)
      end
    end

    def delete
      job = Clockface::ClockworkScheduledJob.find_by_id(params[:job_id])

      unless job
        redirect_to jobs_path
        flash[:error] = t("clockface.jobs.delete.validation.invalid_id")
        return
      end

      @job = Clockface::JobsPresenter.new(job)
      @captcha = captcha_for(job)
    end

    def destroy
      job = Clockface::ClockworkScheduledJob.find_by_id(params[:id])

      if !job
        flash[:error] =
          t("clockface.jobs.destroy.job_not_found", id: params[:id])
        redirect_to jobs_path
        return
      end

      if (params[:captcha] || "") != captcha_for(job)
        flash[:error] = t("clockface.jobs.destroy.validation.incorrect_captcha")
        redirect_to job_delete_path(job)
        return
      end

      if job.destroy
        flash[:success] = t("clockface.jobs.destroy.success")
        clockface_log(:info, "Destroyed Job: #{job.inspect}")
        redirect_to jobs_path
      else
        flash[:error] = t("clockface.jobs.destroy.failure")
        redirect_to job_delete_path(job)
      end
    end

    private

    def all_jobs
      Clockface::ClockworkScheduledJob.includes(:task).order(:id)
    end

    def jobs_params_for_create
      params.require(:clockwork_scheduled_job).permit(
        :clockface_task_id,
        :name,
        :enabled,
        :period_value,
        :period_units,
        :day_of_week,
        :hour,
        :minute,
        :time_zone,
        :if_condition
      ).tap do |params|
        params[:hour] = nil if params[:hour] == "**"
        params[:minute] = nil if params[:minute] == "**"
      end
    end

    def jobs_params_for_update
      params.require(:clockwork_scheduled_job).permit(
        :name,
        :enabled,
        :period_value,
        :period_units,
        :day_of_week,
        :hour,
        :minute,
        :time_zone,
        :if_condition
      ).tap do |params|
        params[:hour] = nil if params[:hour] == "**"
        params[:minute] = nil if params[:minute] == "**"
      end
    end

    def validate_job(job)
      Clockface::JobValidationInteractor.call(job: job, action: params[:action])
    end

    def captcha_for(job)
      Digest::SHA1.hexdigest(job.id.to_s).first(CAPTCHA_LENGTH)
    end
  end
end
