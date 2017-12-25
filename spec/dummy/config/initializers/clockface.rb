Clockface::Engine.configure do |app|
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"
  app.config.clockface.logger = [
    Rails.logger,
    Logger.new(Rails.root.join("log", "clockface.log"))
  ]
  app.config.clockface.tenant_list = ALL_TENANTS
end
