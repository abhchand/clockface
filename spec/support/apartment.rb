RSpec.configure do |config|
  # No need to create each tenant, just pick one for testing purposes

  config.before(:suite) do
    Apartment::Tenant.create("earth")
  end

  config.after(:suite) do
    Apartment::Tenant.drop("earth")
  end
end
