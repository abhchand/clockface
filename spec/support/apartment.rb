RSpec.configure do |config|
  config.before(:suite) do
    ALL_TENANTS.each { |t| Apartment::Tenant.create(t) }
  end

  config.after(:suite) do
    ALL_TENANTS.each { |t| Apartment::Tenant.drop(t) }
  end
end
