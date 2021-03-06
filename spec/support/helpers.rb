require_relative "translation_helpers"
require_relative "tenancy_helpers"
require_relative "subdomain_helpers"
require_relative "capybara_helpers"

%w[views controllers].each do |subdirectory|
  Dir[Rails.root.join("spec/support/#{subdirectory}/*.rb")].each do |file|
    require file
  end
end

RSpec.configure do |config|
  config.include Clockface::ConfigHelper
  config.include TranslationHelpers
  config.include TenancyHelpers

  config.include ViewHelpers, type: :view
  config.include Clockface::Engine.routes.url_helpers, type: [:view]

  config.include SubdomainHelpers, type: :feature
  config.include CapybaraHelpers, type: :feature
end
