RSpec.configure do |config|
  # NOTE - The `apartment` initializer in the dummy host app defines the
  # list of tenants (`TENANTS`) for the test tier. Ideally that info should
  # be defined along with all other Rspec configuration, but for readability
  # it makes sense to have `TENANTS` consistently set in one place. It also
  # avoids having to stub or rebuild that constant, which we'd need to do if
  # setting that from here.

  config.before(:suite) do
    TENANTS.each { |t| Apartment::Tenant.create(t) }
  end

  config.after(:suite) do
    TENANTS.each { |t| Apartment::Tenant.drop(t) }
  end
end
