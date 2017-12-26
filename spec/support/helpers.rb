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
end
