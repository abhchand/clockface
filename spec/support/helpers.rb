%w(views controllers).each do |subdirectory|
  Dir[Rails.root.join("spec/support/#{subdirectory}/*.rb")].each do |file|
    require file
  end
end

require Rails.root.join("spec/support/translation_helpers.rb")
require Rails.root.join("spec/support/tenancy_helpers.rb")

RSpec.configure do |config|
  config.include Clockface::ConfigHelper
  config.include TranslationHelpers
  config.include TenancyHelpers

  config.include ViewHelpers, type: :view
  config.include Clockface::Engine.routes.url_helpers, type: [:view]

  config.before(:each) do
    # In the initializers we set up the test environment as mult-tenant so
    # that it creates the correct DB schemas on startup. However we want to
    # treat single tenancy as the default, so mock it before each spec
    # Those specs that require multi-tenancy enabled can mock it accordingly
    enable_single_tenancy!
  end
end
