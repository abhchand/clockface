module TenancyHelpers
  def enable_single_tenancy!
    allow(
      Clockface::Engine.config.clockface
    ).to receive(:tenant_list) { [] }
  end

  def enable_multi_tenancy!
    allow(
      Clockface::Engine.config.clockface
    ).to receive(:tenant_list) { TENANTS }
  end
end
