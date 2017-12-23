source 'https://rubygems.org'
gemspec

# gemspec definitions aren't great for managing various groups. For instance,
# they don't provide an easy way to add to a `test` group.
#
# Define development and test dependencies here instead

group :development do
  gem 'foreman'
end

group :development, :test do
  gem "apartment-sidekiq"
  gem "apartment"
  gem 'capybara-webkit', '~> 1.11.1'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'pg'
  gem 'pry-rails'
  gem 'rails-controller-testing', '~> 1.0', '>= 1.0.1'
  gem 'redis'
  gem 'rspec-rails', '>= 3.5'
  gem 'shoulda-matchers'
  gem 'sidekiq'
end
