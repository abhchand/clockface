module Clockface
  class ApplicationController < ActionController::Base
    include ConfigHelper
    include ClockfaceLoggingHelper

    protect_from_forgery with: :exception

    private

    def xhr_request?
      (defined? request) && request.xhr?
    end
  end
end
