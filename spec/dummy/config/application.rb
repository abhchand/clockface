require_relative 'boot'

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
# require "active_job/railtie"
# require "rails/test_unit/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

# The host application should not auto-require clockface. The host clock
# configuration file will require it directly
# Leaving commented-out version in place for searchability and documentation
# See `lib/clockface.rb` for more information
# require "clockface"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = "UTC"
  end
end

