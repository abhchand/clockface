require "bootstrap-sass"
require "inline_svg"
require "interactor"
require "jquery-rails"

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
      ClockfaceConfig = Struct.new(:logger)

      app.config.clockface = ClockfaceConfig.new
      app.config.clockface.logger = ""
    end
  end
end
