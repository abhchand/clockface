module SubdomainHelpers
  # rubocop:disable Lint/UnusedMethodArgument
  def with_subdomain(subdomain, &block)
    # rubocop:enable Lint/UnusedMethodArgument
    saved_values = [Capybara.app_host, Capybara.always_include_port]
    host = "http://#{subdomain == 'public' ? 'www' : subdomain}.lvh.me"

    begin
      set_host(host, true)
      tenant(subdomain) { yield }
    ensure
      set_host(*saved_values)
    end
  end

  def set_host(host, include_port)
    Capybara.app_host = host
    Capybara.always_include_port = include_port
  end
end
