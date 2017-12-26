def multi_tenancy_enabled?
  ![nil, "", "false", 0, "0"].include?(ENV["MULTI_TENANT"])
end
