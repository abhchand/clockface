def formatted_env
  case Rails.env
  when "development"
    Pry::Helpers::Text.green(Rails.env)
  else
    Rails.env
  end
end

def formatted_tenant
  respond_to?(:tenant) ? "[#{tenant}]" : ""
end

if defined?(Rails)
  Pry.config.prompt = proc do |obj, nest_level, pry|
    [
      "[#{pry.input_array.size}]",
      "[#{formatted_env}]#{formatted_tenant}",
      "#{obj}:#{nest_level}> "
    ].join(" ")
  end
end
