require "bootstrap-sass"
require "inline_svg"
require "interactor"

module Clockface
  class Engine < ::Rails::Engine
    isolate_namespace Clockface

    config.generators do |generate|
      generate.factory_girl true
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

    # Ensure this initializer runs before the host applications initializers
    # so that the config structure gets defined.
    initializer "clockface.config", before: :load_config_initializers do |app|
      ClockfaceConfig = Struct.new(
        :time_zone,
        :logger,
        :tenant_list,
        :current_tenant_proc,
        :execute_in_tenant_proc
      )

      app.config.clockface = ClockfaceConfig.new
      app.config.clockface.time_zone = Rails.application.config.time_zone
      app.config.clockface.logger = Logger.new(STDOUT)
      app.config.clockface.tenant_list = []

      # Out-of-the-box functionality support for the Apartment gem, if the
      # host app is using it
      app.config.clockface.current_tenant_proc =
        if defined?(Apartment)
          Proc.new do
            Apartment::Tenant.current
          end
        end

      app.config.clockface.execute_in_tenant_proc =
        if defined?(Apartment)
          Proc.new do |tenant_name, some_proc|
            Apartment::Tenant.switch(tenant_name) { some_proc.call }
          end
        end
    end
  end
end
