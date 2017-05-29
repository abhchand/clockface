require "shoulda/matchers"

# See various fixes outlined here:
# https://github.com/thoughtbot/shoulda/issues/203#issuecomment-148065421
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

