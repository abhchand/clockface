ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require "spec_helper"
require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"

require "shoulda/matchers"

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

# Require all support files
Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryGirl::Syntax::Methods
end

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.javascript_driver = :webkit
end

Capybara::Screenshot.autosave_on_failure = false

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
