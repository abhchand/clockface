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

    def show
    end

    def edit
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
