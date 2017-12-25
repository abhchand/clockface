Clockface::Engine.configure do |app|
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"
  app.config.clockface.logger = Rails.logger
  app.config.clockface.tenant_list = ALL_TENANTS
  # Let these default since we use the apartment gem
  # app.config.clockface.current_tenant_proc =
  # app.config.clockface.execute_in_tenant_proc =
end
