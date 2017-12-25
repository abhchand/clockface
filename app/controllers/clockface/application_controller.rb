module Clockface
  class ApplicationController < ActionController::Base
    include ClockfaceConfigHelper

    protect_from_forgery with: :exception

    def log(level, msg)
      clockface_logger.send(level, "[Clockface] #{msg}")
    end

    private

    def xhr_request?
      (defined? request) && request.xhr?
    end
  end
end
