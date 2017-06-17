module Clockface
  class JobsController < ApplicationController
    def index
      @jobs = all_jobs.map { |job| Clockface::JobsPresenter.new(job) }
    end

    def new
      @default_timezone = Clockface::ClockworkScheduledJob.last.try(:timezone)
    end

    def create
    end

    def edit
      @job = Clockface::ClockworkScheduledJob.find_by_id(params[:id])

      unless @job
        redirect_to jobs_path
        flash[:error] = t("clockface.jobs.edit.validation.invalid_id")
      end
    end

    def update
    end

    def destroy
    end

    private

    def all_jobs
      Clockface::ClockworkScheduledJob.includes(:event).order(:id)
    end
  end
end
