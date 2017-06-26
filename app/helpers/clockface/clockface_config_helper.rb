module Clockface
  module ClockfaceConfigHelper
    def clockface_time_zone
      tz = Clockface::Engine.config.clockface.time_zone
      ActiveSupport::TimeZone::MAPPING.key?(tz) ? tz : "UTC"
    end

    def clockface_logger
      Clockface::Engine.config.clockface.logger
    end

    def clockface_tenant_list
      Clockface::Engine.config.clockface.tenant_list
    end

    def clockface_multi_tenancy_enabled?
      clockface_tenant_list.any?
    end
  end
end
