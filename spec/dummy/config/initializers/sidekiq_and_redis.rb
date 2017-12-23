require "sidekiq/web"

# Define a Sidekiq wrapper around the redis connections so that all calls to
# redis go through Sidekiq and this wrapper. It not only configures the redis
# connection but it essentially forwards all redis calls to Sidekiq which
# internally manages the connection pool
class SidekiqRedisConnectionWrapper
  unless defined? URL
    URL = "redis://localhost:6379/"
  end

  def initialize
    Sidekiq.configure_server do |config|
      config.redis = { url: URL, network_timeout: 3 }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: URL, network_timeout: 3, size: 3 }
    end
  end

  def method_missing(meth, *args, &block)
    Sidekiq.redis do |connection|
      connection.send(meth, *args, &block)
    end
  end

  def respond_to_missing?(meth)
    Sidekiq.redis do |connection|
      connection.respond_to?(meth)
    end
  end
end

$redis = SidekiqRedisConnectionWrapper.new


# Have Sidekiq use the Rails logger
Sidekiq::Logging.logger = Rails.logger
