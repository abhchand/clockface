require "capybara/rails"
require "capybara/rspec"
require "capybara-webkit"

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.javascript_driver = :webkit
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
