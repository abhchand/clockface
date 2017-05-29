require "factory_girl_rails"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  # TODO: These don't relate to FactoryGirl or fixtures, but they fail
  # when placed inside spec_helper. Find out why.
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
