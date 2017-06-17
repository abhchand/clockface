module Clockface
  class JobValidationInteractor
    include Interactor

    after { context.fail! if context.errors.any? }

    def call
      context.errors = []

      handle_invalid_model unless model_valid?
      handle_duplicate_job if duplicate_job?
    end

    private

    def model_valid?
      context.job.valid?
    end

    def duplicate_job?
      Clockface::ClockworkScheduledJob.find_duplicates_of(context.job).any?
    end

    def handle_invalid_model
      context.job.errors.messages.each do |attribute, messages|
        context.errors << messages.first
      end
    end

    def handle_duplicate_job
      context.errors << I18n.t("clockface.jobs.#{context.action}.duplicate_job")
    end
  end
end
