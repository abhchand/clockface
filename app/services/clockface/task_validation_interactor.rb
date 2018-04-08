module Clockface
  class TaskValidationInteractor
    include Interactor

    after { context.fail! if context.errors.any? }

    def call
      context.errors = []

      handle_invalid_model unless model_valid?
    end

    private

    def model_valid?
      context.task.valid?
    end

    def handle_invalid_model
      context.task.errors.messages.each_value do |messages|
        context.errors << messages.first
      end
    end
  end
end
