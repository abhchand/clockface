require "bootstrap-sass"

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
  end
end
