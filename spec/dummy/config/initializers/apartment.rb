require 'apartment/elevators/generic'
require 'apartment/elevators/subdomain'
require 'apartment/elevators/first_subdomain'

ALL_TENANTS =
  case
  when Rails.env.development?
    %w(mercury venus earth mars)
  when Rails.env.test?
    %w(mercury venus)
  else
    raise "Only development and test environments allowed!"
  end

Apartment.configure do |config|
  config.tenant_names = ALL_TENANTS
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

def each_tenant(&block)
  raise "No block sepcified!" unless block_given?

  ALL_TENANTS.each do |tenant_name|
    puts "==== #{tenant_name}"
    tenant(tenant_name) { yield(tenant_name) }
  end
end
