Clockface::Engine.configure do |app|
  # Test locally with some time other than UTC
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"

  # Log to a dedicated Clockface log file to easily follow activity on
  # development
  app.config.clockface.logger = [
    Rails.logger,
    Logger.new(Rails.root.join("log", "clockface.log"))
  ]

  # This dummy app is used exclusively for development testing, so our tenant
  # list will be whatever Apartment was configured with in the `apartment`
  # initializer
  app.config.clockface.tenant_list = Apartment.tenant_names
end
