module Clockface
  module EventsHelper
    include ConfigHelper

    def event_form_select_options_for_name
      Clockface::Task.order(:id).collect { |e| [ e.name, e.id ] }
    end

    def event_form_select_options_for_period_units
      Clockface::Event::PERIOD_UNITS.map do |unit|
        [ t("datetime.units.#{unit}"), unit ]
      end
    end

    def event_form_select_options_for_day_of_week
      t("date.day_names").each_with_index.map { |day, i| [ day, i ] }
    end

    def event_form_select_options_for_hour
      (["**"] + (0..23).to_a).map { |h| [ h.to_s.rjust(2, "0"), h ] }
    end

    def event_form_select_options_for_minute
      (["**"] + (0..59).to_a).map { |m| [ m.to_s.rjust(2, "0"), m ] }
    end

    def event_form_select_options_for_if_condition
      Clockface::Event::IF_CONDITIONS.keys.map do |if_condition|
        [
          Clockface::Event.
            human_attribute_name("if_condition.#{if_condition}"),
          if_condition
        ]
      end
    end
  end
end
