source "https://rubygems.org"
gemspec

group :development do
  gem "apartment", require: false
  gem "foreman"
  gem "rubocop", "~> 0.57.2"
end

group :test do
  gem "apartment"
end

group :development, :test do
  gem "apartment-sidekiq"
  gem "capybara-webkit", "~> 1.11.1"
  gem "factory_girl_rails"
  gem "pg"
  gem "pry-rails"
  gem "rails-controller-testing", "~> 1.0", ">= 1.0.1"
  gem "redis"
  gem "rspec-rails", ">= 3.5"
  gem "shoulda-matchers"
  gem "sidekiq"

  # Nokogiri has a flagged vulnerability for < 1.8.1
  # Capybara requires it indirectly, so maintain this explicit version until
  # we upgrade capybara to match
  gem "nokogiri", ">= 1.8.1"
end
