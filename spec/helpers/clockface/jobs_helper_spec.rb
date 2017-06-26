require "rails_helper"

module Clockface
  RSpec.describe JobsHelper, type: :helper do
    describe "#job_form_select_options_for_tenant" do
      it "returns the select options for tenant" do
        Clockface::Engine.config.clockface.tenant_list = %w(foo bar)

        expect(job_form_select_options_for_tenant).to eq(
          [ [ "foo", "foo" ], [ "bar", "bar" ] ]
        )
      end
    end

    describe "#job_form_select_options_for_name" do
      it "returns the select options for name" do
        event1 = create(:clockwork_event)
        event2 = create(:clockwork_event)

        expect(job_form_select_options_for_name).to eq(
          [ [ event1.name, event1.id ], [ event2.name, event2.id ] ]
        )
      end
    end

    describe "#job_form_select_options_for_period_units" do
      it "returns the select options for period_units" do
        result = job_form_select_options_for_period_units

        expect(result.size).
          to eq(Clockface::ClockworkScheduledJob::PERIOD_UNITS.size)
        expect(result.first[1]).
          to eq(Clockface::ClockworkScheduledJob::PERIOD_UNITS.first)
        expect(result.last[1]).
          to eq(Clockface::ClockworkScheduledJob::PERIOD_UNITS.last)
      end
    end

    describe "#job_form_select_options_for_day_of_week" do
      it "returns the select options for day_of_week" do
        result = job_form_select_options_for_day_of_week

        expect(result.size).to eq(t("date.day_names").size)
        expect(result.first[1]).to eq(0)
        expect(result.last[1]).to eq(6)
      end
    end

    describe "#job_form_select_options_for_hour" do
      it "returns the select options for hour" do
        result = job_form_select_options_for_hour

        expect(result.size).to eq(24 + 1)
        expect(result.first[1]).to eq("**")
        expect(result.last[1]).to eq(23)
      end
    end

    describe "#job_form_select_options_for_minute" do
      it "returns the select options for minute" do
        result = job_form_select_options_for_minute

        expect(result.size).to eq(60 + 1)
        expect(result.first[1]).to eq("**")
        expect(result.last[1]).to eq(59)
      end
    end

    describe "#job_form_select_options_for_if_condition" do
      it "returns the select options for if_condition" do
        keys = Clockface::ClockworkScheduledJob::IF_CONDITIONS.keys
        result = job_form_select_options_for_if_condition

        expect(result.size).to eq(keys.size)
        expect(result.first[1]).to eq(keys.first)
        expect(result.last[1]).to eq(keys.last)
      end
    end
  end
end
