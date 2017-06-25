class ExampleWorker
  include Sidekiq::Worker

  def perform(id)
    # Log to a dedicated log file to easily isolate messages while testing
    logger = Logger.new(Rails.root.join("log", "example_worker.log"))

    message = "Running Example Worker with id: #{id}"

    Sidekiq.logger.info(message)
    logger.info(message)
  end
end
