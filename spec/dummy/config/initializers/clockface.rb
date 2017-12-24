Clockface::Engine.configure do |app|
  app.config.clockface.time_zone = "Pacific Time (US & Canada)"
  app.config.clockface.logger = Rails.logger
  app.config.clockface.tenant_list = %w(venus earth mars)
  app.config.clockface.before_action = Proc.new { tenant("public") }
end
