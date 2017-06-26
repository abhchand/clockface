module Clockface
  module ClockfaceConfigHelper
    def clockface_timezone
      tz = Clockface::Engine.config.clockface.time_zone
      ActiveSupport::TimeZone::MAPPING.key?(tz) ? tz : "UTC"
    end

    def clockface_logger
      Clockface::Engine.config.clockface.logger
    end
  end
end
