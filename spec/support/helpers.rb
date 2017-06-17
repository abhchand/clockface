%w(views controllers).each do |subdirectory|
  Dir[Rails.root.join("spec/support/#{subdirectory}/*.rb")].each do |file|
    require file
  end
end

RSpec.configure do |config|
  config.include ViewHelpers, type: :view
  config.include Clockface::Engine.routes.url_helpers, type: :view
  config.include ControllerHelpers, type: :controller
end
