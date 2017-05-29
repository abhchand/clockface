ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)

if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require "spec_helper"
require "rspec/rails"
require "shoulda/matchers"
Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!
