ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)

if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require "spec_helper"
require "rspec/rails"

# Only require the top-level files that are one level deep
# All support/** sub-folders should be required by the top-level files
Dir[Rails.root.join("spec/support/*.rb")].each { |file| require file }
