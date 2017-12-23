# desc "Create tenants if they don't exist locally"

# task :create_tenants => :environment do
#   unless Rails.env == "development"
#     raise "Task only available on development"
#   end

#   Apartment::tenant_names.each do |t|
#     begin
#       tenant(t) { User.count }
#       puts "Tenant \"#{t}\" exists"
#     rescue Apartment::TenantNotFound
#       puts "Creating tenant \"#{t}\""
#       Apartment::Tenant.create(t)
#     end
#   end
# end

namespace :apartment do
  desc "Create all tenants"
  task :create_tenants => :environment do
    unless Rails.env == "development"
      raise "Task only available on development"
    end

    Apartment::tenant_names.each do |tenant|
      begin
        puts("Creating #{tenant} tenant")
        Apartment::Tenant.create(tenant)
      rescue Apartment::TenantExists => e
        puts e.message
      end
    end
  end
end
