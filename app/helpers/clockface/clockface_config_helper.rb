module Clockface
  module ClockfaceConfigHelper
    def clockface_time_zone
      tz = Clockface::Engine.config.clockface.time_zone
      ActiveSupport::TimeZone::MAPPING.key?(tz) ? tz : "UTC"
    end

    def clockface_tenant_list
      Clockface::Engine.config.clockface.tenant_list
    end

    def clockface_multi_tenancy_enabled?
      clockface_tenant_list.any?
    end

    def clockface_current_tenant
      Clockface::Engine.config.clockface.current_tenant_proc.call
    end

    def clockface_execute_in_tenant(tenant_name, some_proc)

      Clockface::Engine.config.clockface.execute_in_tenant_proc.call(
        tenant_name,
        some_proc
      )
    end
  end
end
