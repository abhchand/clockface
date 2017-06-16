require "rails_helper"

module Clockface
  RSpec.feature "Flash", type: :feature do
    include Clockface::Engine.routes.url_helpers

    # it "user can view and close the flash", :js do
    #   visit edit_job_path(1)
    #   expect(current_path).to eq(jobs_path)
    # end
  end
end
