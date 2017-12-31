require "rails_helper"

module Clockface
  RSpec.describe EventsHelper, type: :helper do
    describe "#event_form_select_options_for_name" do
      it "returns the select options for name" do
        task1 = create(:task)
        task2 = create(:task)

        expect(event_form_select_options_for_name).to eq(
          [[task1.name, task1.id], [task2.name, task2.id]]
        )
      end
    end

    describe "#event_form_select_options_for_period_units" do
      it "returns the select options for period_units" do
        result = event_form_select_options_for_period_units

        expect(result.size).
          to eq(Clockface::Event::PERIOD_UNITS.size)
        expect(result.first[1]).
          to eq(Clockface::Event::PERIOD_UNITS.first)
        expect(result.last[1]).
          to eq(Clockface::Event::PERIOD_UNITS.last)
      end
    end

    describe "#event_form_select_options_for_day_of_week" do
      it "returns the select options for day_of_week" do
        result = event_form_select_options_for_day_of_week

        expect(result.size).to eq(t("date.day_names").size)
        expect(result.first[1]).to eq(0)
        expect(result.last[1]).to eq(6)
      end
    end

    describe "#event_form_select_options_for_hour" do
      it "returns the select options for hour" do
        result = event_form_select_options_for_hour

        expect(result.size).to eq(24 + 1)
        expect(result.first[1]).to eq("**")
        expect(result.last[1]).to eq(23)
      end
    end

    describe "#event_form_select_options_for_minute" do
      it "returns the select options for minute" do
        result = event_form_select_options_for_minute

        expect(result.size).to eq(60 + 1)
        expect(result.first[1]).to eq("**")
        expect(result.last[1]).to eq(59)
      end
    end

    describe "#event_form_select_options_for_if_condition" do
      it "returns the select options for if_condition" do
        keys = Clockface::Event::IF_CONDITIONS.keys
        result = event_form_select_options_for_if_condition

        expect(result.size).to eq(keys.size)
        expect(result.first[1]).to eq(keys.first)
        expect(result.last[1]).to eq(keys.last)
      end
    end
  end
end
