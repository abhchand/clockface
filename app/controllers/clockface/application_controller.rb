module Clockface
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def log(level, msg)
      Clockface::Engine.config.clockface.logger.
        send(level, "[Clockface] #{msg}")
    end

    private

    def xhr_request?
      (defined? request) && request.xhr?
    end
  end
end
