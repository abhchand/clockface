module Clockface
  class ApplicationController < ActionController::Base
    include ClockfaceConfigHelper

    protect_from_forgery with: :exception

    before_action :run_user_defined_before_action

    def log(level, msg)
      clockface_logger.send(level, "[Clockface] #{msg}")
    end

    private

    def xhr_request?
      (defined? request) && request.xhr?
    end

    def run_user_defined_before_action
      if clockface_before_action.respond_to?(:call)
        clockface_before_action.call
      end
    end
  end
end
