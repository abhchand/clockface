module Clockface
  module LoggingHelper
    def clockface_log(level, msg)
      # Clockface logger can be a single `Logger` or an array of many `Logger`s
      logs = Clockface::Engine.config.clockface.logger
      logs = [logs] unless logs.is_a?(Array)

      # Log to each individual logger
      logs.each { |log| log.send(level, "[Clockface] #{msg}") }
    end
  end
end
