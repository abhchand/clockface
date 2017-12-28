require "capybara/rails"
require "capybara/rspec"
require "capybara-webkit"

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  Capybara.default_driver = :webkit
  config.javascript_driver = :webkit
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.allow_url("lvh.me")
end

RSpec.configure do |config|
  config.before(:suite) do
    Capybara.always_include_port = true
    # The default is to treat each spec as single tennat, in which case
    # we want to hit localhost. Hitting the Capbyara default of www.example.com
    # causes the apartment setup to try and parse the `www` as a subdomain
    Capybara.app_host = "http://localhost"
  end

  config.before(:each, multi_tenant: true) do
    # For multi-tenant specs, use "lvh.me", although this will often be
    # overridden with thelp of the `with_subdomain` helper
    Capybara.app_host = "http://lvh.me"
  end
end
