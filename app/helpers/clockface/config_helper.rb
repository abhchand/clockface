module Clockface
  module ConfigHelper
    def clockface_time_zone
      tz = Clockface::Engine.config.clockface.time_zone
      ActiveSupport::TimeZone::MAPPING.key?(tz) ? tz : "UTC"
    end

    def clockface_tenant_list
      Clockface::Engine.config.clockface.tenant_list
    end

    def clockface_single_tenancy_enabled?
      clockface_tenant_list.empty?
    end

    def clockface_multi_tenancy_enabled?
      clockface_tenant_list.any?
    end

    def clockface_current_tenant
      Clockface::Engine.config.clockface.current_tenant_proc.call
    end

    def clockface_execute_in_tenant(tenant_name, some_proc, proc_args = [])
      Clockface::Engine.config.clockface.execute_in_tenant_proc.call(
        tenant_name,
        some_proc,
        proc_args
      )
    end
  end
end
