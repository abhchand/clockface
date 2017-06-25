class ExampleWorker
  include Sidekiq::Worker

  def perform(id)
    Sidekiq.logger.info "Running Example Worker with id: #{id}"
  end
end
