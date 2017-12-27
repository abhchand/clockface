def multi_tenancy_enabled?
  ENV.key?("MULTI_TENANT") &&
    ![nil, "", "false", 0, "0"].include?(ENV["MULTI_TENANT"])
end
