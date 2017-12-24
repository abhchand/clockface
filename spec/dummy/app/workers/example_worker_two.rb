class ExampleWorkerTwo
  include Sidekiq::Worker

  def perform
    message = "[#{tenant}] Running Example Worker Two"

    Sidekiq.logger.info(message)

    # Also log to a dedicated log file to easily isolate messages while testing
    logger = Logger.new(Rails.root.join("log", "example_workers.log"))
    logger.info(message)
  end
end
