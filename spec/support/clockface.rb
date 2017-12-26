require_relative "helpers"

RSpec.configure do |config|
  config.before(:each) do
    # In the initializers we set up the test environment as mult-tenant so
    # that it creates the correct DB schemas on startup. However we want to
    # treat single tenancy as the default, so mock it before each spec
    # Those specs that require multi-tenancy enabled can mock it accordingly
    enable_single_tenancy!
  end
end
