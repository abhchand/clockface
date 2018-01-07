module Clockface
  class ApplicationController < ActionController::Base
    include ConfigHelper
    include LoggingHelper

    CAPTCHA_LENGTH = 5

    protect_from_forgery with: :exception

    private

    def xhr_request?
      (defined? request) && request.xhr?
    end

    def captcha_for(obj)
      Digest::SHA1.hexdigest(obj.id.to_s).first(CAPTCHA_LENGTH)
    end
  end
end
