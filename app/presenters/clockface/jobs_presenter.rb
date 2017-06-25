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
      at = job.at

      # `at` uses the day name from the ruby standard library - Date::DAYNAMES
      # Need to replace that with the translated version for any given locale
      if job.day_of_week.present?
        at.gsub!(
          Date::DAYNAMES[job.day_of_week],
          I18n.t("date.day_names")[job.day_of_week]
        )
      end

      at
    end

    def if_condition
      if job.if_condition.present?
        Clockface::ClockworkScheduledJob.
          human_attribute_name("if_condition.#{job.if_condition}")
      end
    end

    def last_run_at
      if job.last_run_at
        job.last_run_at.
          in_time_zone(Clockface::Engine.config.clockface.time_zone).
          strftime(I18n.t("datetime.formats.international"))
      end
    end

    private

    def job
      __getobj__
    end
  end
end
