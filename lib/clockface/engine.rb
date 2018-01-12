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
      app.config.clockface.logger = Rails.logger
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
          Proc.new do |tenant_name, some_proc, proc_args|
            Apartment::Tenant.switch(tenant_name) { some_proc.call(*proc_args) }
          end
        end
    end

    # Ensure this initializer runs after the host applications initializers
    # so it can verify what was configured
    initializer "clockface.validate", after: :load_config_initializers do |app|
      # Time Zone
      time_zone = app.config.clockface.time_zone
      valid_time_zones = ActiveSupport::TimeZone::MAPPING.keys
      unless valid_time_zones.include?(time_zone)
        raise "Invalid time zone #{time_zone}"
      end

      # Log
      loggers = app.config.clockface.logger
      loggers = [loggers] unless loggers.is_a?(Array)
      methods = [:debug, :info, :warn, :error, :fatal]
      loggers.each do |logger|
        methods.each do |m|
          unless logger.respond_to?(m)
            raise "At least one logger is invalid. Did not respond to `:#{m}`"
          end
        end
      end

      # Tenant List
      app.config.clockface.tenant_list = app.config.clockface.tenant_list.uniq

      # Current Tenant
      p = app.config.clockface.current_tenant_proc
      if app.config.clockface.tenant_list.any? && p.blank?
        raise "`current_tenant_proc` must be defined for multi-tenant mode"
      end

      # Execute In Tenant
      p = app.config.clockface.execute_in_tenant_proc
      if app.config.clockface.tenant_list.any? && p.blank?
        raise "`execute_in_tenant_proc` must be defined for multi-tenant mode"
      end
    end
  end
end
