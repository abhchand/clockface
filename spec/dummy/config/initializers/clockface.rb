Clockface::Engine.configure do |app|
  # Test locally with some time other than UTC
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"

  # Log to both the Rails logger as well as a dedicated logger
  app.config.clockface.logger =
    [Rails.logger, Logger.new(Rails.root.join("log", "clockface.log"))]

  app.config.clockface.tenant_list = Apartment.tenant_names
end
