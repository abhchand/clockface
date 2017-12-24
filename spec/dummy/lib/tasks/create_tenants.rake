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
