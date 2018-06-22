def run_as_multi_tenant?
  ENV.key?("RUN_AS_MULTI_TENANT") &&
    ![nil, "", "false", 0, "0"].include?(ENV["RUN_AS_MULTI_TENANT"])
end
