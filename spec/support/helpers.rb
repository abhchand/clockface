%w(views controllers).each do |subdirectory|
  Dir[Rails.root.join("spec/support/#{subdirectory}/*.rb")].each do |file|
    require file
  end
end

require Rails.root.join("spec/support/translation_helpers.rb")

RSpec.configure do |config|
  config.include TranslationHelpers

  config.include ViewHelpers, type: :view
  config.include Clockface::Engine.routes.url_helpers, type: [:view]

  config.before(:each) do
    Clockface::Engine.config.clockface.time_zone = "UTC"
    Clockface::Engine.config.clockface.logger = Rails.logger
    Clockface::Engine.config.clockface.tenant_list = []
  end
end
