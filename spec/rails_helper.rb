# Run the Rails environment initialization in multi tenant mode so that
# it creates the necessary tenant schemas on startup. We use stubs to disguise
# the app as single or multi tenancy for each spec
# See: `support/clockface` and `support/tenancy_helpers`
ENV["RUN_AS_MULTI_TENANT"] = "1"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("dummy/config/environment", __dir__)

if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require "spec_helper"
require "rspec/rails"

# Only require the top-level files that are one level deep
# All support/** sub-folders should be required by the top-level files
Dir[Rails.root.join("spec/support/*.rb")].each { |file| require file }

# Maintain the test schema to match the development schema at all times
ActiveRecord::Migration.maintain_test_schema!
