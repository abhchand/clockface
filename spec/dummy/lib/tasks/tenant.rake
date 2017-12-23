desc "Main dependency for multi-tenant tasks"
task :tenant, [:args] => :environment do |t, args|
  unless args[:tenant]
    raise "Tenant must be specified (e.g. `rake my_task['globex']`)"
  end

  args[:tenant].downcase!
end

def run_rake_task(opts = {}, &block)
  task = opts.fetch(:task)
  args = opts.fetch(:args)
  uid = SecureRandom.hex
  start = Time.zone.now

  # `args` is of type `Rake::TaskArguments` so `fetch` won't work. Check for
  # key presence manually
  tenant_name = args[:tenant]
  raise "No tenant provided" unless tenant_name.present?

  start_text = "Rake START - {task: \"#{task}\", uid: #{uid}, args: #{args}}"
  Rails.logger.info(start_text)
  puts start_text

  tenant(tenant_name) do
    yield
  end

  elapsed = "#{(Time.zone.now - start).round(3)} sec"
  stop_text =
    "Rake STOP (#{elapsed})- {task: \"#{task}\", uid: #{uid}, args: #{args}}"
  Rails.logger.info(stop_text)
  puts(stop_text)
end
