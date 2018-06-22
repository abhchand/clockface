if run_as_multi_tenant?
  require "apartment/elevators/generic"
  require "apartment/elevators/subdomain"
  require "apartment/elevators/first_subdomain"

  TENANTS = %w[earth mars].freeze

  Apartment.configure do |config|
    config.tenant_names = TENANTS
  end

  Rails.application.config.middleware.use Apartment::Elevators::FirstSubdomain

  def tenant(tenant = nil)
    if tenant
      if block_given?
        Apartment::Tenant.switch(tenant) { yield }
      else
        Apartment::Tenant.switch! tenant
      end
    else
      Apartment::Tenant.current
    end
  end
end
