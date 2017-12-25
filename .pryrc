def formatted_env
  Pry::Helpers::Text.green(Rails.env)
end

if defined?(Rails)
  Pry.config.prompt = proc do |obj, nest_level, pry|
    [
      "[#{pry.input_array.size}]",
      "[#{formatted_env}][#{tenant}]",
      "#{obj}:#{nest_level}> "
    ].join(" ")
  end
end

unless Rails.env.test?
  puts "Setting tentant as \"mercury\""
  tenant("mercury")
end
