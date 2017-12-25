require "rails_helper"

module Clockface
  RSpec.describe ApplicationController, type: :controller do
    controller do
      def index
        @output = User.first.email
        render plain: "foo"
      end
    end
  end
end
