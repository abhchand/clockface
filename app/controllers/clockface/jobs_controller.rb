module Clockface
  class JobsController < ApplicationController
    def index
      @jobs = Clockface::ClockworkScheduledJob.all
    end

    def new
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
  end
end
