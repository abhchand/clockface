def multi_tenancy_enabled?
  ![nil, "", "false", 0, "0"].include?(ENV["MULTITENANT"])
end
