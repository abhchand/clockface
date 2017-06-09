module Clockface
  class DashboardController < ApplicationController
    def show
      @scheduled_jobs = Clockface::ClockworkScheduledJob.all
    end
  end
end
