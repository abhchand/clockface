module Clockface
  class EventValidationInteractor
    include Interactor

    after { context.fail! if context.errors.any? }

    def call
      context.errors = []

      handle_invalid_model unless model_valid?
      handle_duplicate_event if duplicate_event?
    end

    private

    def model_valid?
      context.event.valid?
    end

    def duplicate_event?
      Clockface::Event.find_duplicates_of(context.event).any?
    end

    def handle_invalid_model
      context.event.errors.messages.each do |attribute, messages|
        context.errors << messages.first
      end
    end

    def handle_duplicate_event
      context.errors <<
        I18n.t("clockface.events.#{context.action}.duplicate_event")
    end
  end
end
