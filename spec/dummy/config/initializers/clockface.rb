Clockface::Engine.configure do |app|
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"
  app.config.clockface.logger = Rails.logger
end
