Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # NOTE: It seems to be a bit of a mystery why this is needed. By default it
  # is disabled in the test environment. But when running Capybara webkit
  # driver commands, it throws errors like
  #
  # ActionController::RoutingError:
  #   No route matches [GET] "/assets/clockface/application-af04b226fd...css"
  #
  # Obviously it"s looking for precompiled assets, which don"t exist in test
  # So the workaround is to enable debug mode which forces it to look for
  # uncompiled assets.
  # Taken from: https://stackoverflow.com/a/17145305/2490003
  config.assets.debug = true

  # The test environment is used exclusively to run your application"s
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don"t rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.seconds.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
