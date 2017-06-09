module Clockface
  class DashboardsController < ApplicationController
    def show
      @scheduled_jobs = Clockface::ClockworkScheduledJob.all
    end
  end
end
