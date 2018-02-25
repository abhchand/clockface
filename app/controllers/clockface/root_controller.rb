module Clockface
  class RootController < ApplicationController
    def index
      redirect_to clockface.events_path
    end
  end
end
