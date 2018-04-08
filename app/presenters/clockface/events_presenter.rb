module Clockface
  class EventsPresenter < SimpleDelegator
    include ConfigHelper

    def period
      I18n.t(
        "datetime.distance_in_words.x_#{event.period_units}",
        count: event.period_value
      )
    end

    def at
      at = event.at

      # `at` uses the day name from the ruby standard library - Date::DAYNAMES
      # Here we replace that with the translated version for any given locale
      if event.day_of_week.present?
        at.gsub!(
          Date::DAYNAMES[event.day_of_week],
          I18n.t("date.day_names")[event.day_of_week]
        )
      end

      at
    end

    def if_condition
      return if event.if_condition.blank?

      Clockface::Event.
        human_attribute_name("if_condition.#{event.if_condition}")
    end

    def last_triggered_at
      return unless event.last_triggered_at

      event.last_triggered_at.
        in_time_zone(clockface_time_zone).
        strftime(I18n.t("datetime.formats.international"))
    end

    private

    def event
      __getobj__
    end
  end
end
