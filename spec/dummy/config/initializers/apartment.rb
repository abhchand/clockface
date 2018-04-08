require_relative "multi_tenant"

require "apartment/elevators/generic"
require "apartment/elevators/subdomain"
require "apartment/elevators/first_subdomain"

TENANTS = %w[earth mars].freeze

Apartment.configure do |config|
  config.tenant_names =
    case
    when Rails.env.development?
      # On development, set up as single/multi tenant depending on configuration
      multi_tenancy_enabled? ? TENANTS : []
    when Rails.env.test?
      # On test, always set up as multi-tenant so schemas are created in the
      # DB. The specs will stub as needed to make it appear as single or multi
      # tenant
      TENANTS
    end
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
