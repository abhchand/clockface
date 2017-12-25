module MultiTenancyHelpers
  # Use stubs over actually updating the config since stubs are cleared
  # between specs

  def enable_multi_tenancy!
    allow(
      Clockface::Engine.config.clockface
    ).to receive(:tenant_list) { ALL_TENANTS }
  end

  def disable_multi_tenancy!
    # This assumes the original `tenant_list` is set to `[]`
    # Confirm setting in `spec/support/helpers.rb`
    allow(
      Clockface::Engine.config.clockface
    ).to receive(:tenant_list).and_call_original
  end
end
