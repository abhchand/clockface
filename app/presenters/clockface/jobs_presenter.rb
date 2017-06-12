# TODO: Needs specs
module Clockface
  class JobsPresenter < SimpleDelegator
    def period
      I18n.t(
        "datetime.distance_in_words.x_#{job.period_units}",
        count: job.period_value
      )
    end

    def at
      # TODO: This needs to be properly translatable via I18n
      job.at
    end

    def if_condition
      if job.if_condition.present?
        Clockface::ClockworkScheduledJob.
          human_attribute_name("if_condition.#{job.if_condition}")
      end
    end

    private

    def job
      __getobj__
    end
  end
end
