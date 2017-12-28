require "rails_helper"

module Clockface
  RSpec.describe JobsPresenter do
    let(:job) { create(:clockwork_scheduled_job) }
    let(:presenter) { Clockface::JobsPresenter.new(job) }

    describe "#period" do
      it "returns the translated period" do
        job.update!(period_value: "1", period_units: "weeks")
        expect(presenter.period).to eq("1 week")

        job.update!(period_value: "17", period_units: "hours")
        expect(presenter.period).to eq("17 hours")
      end
    end

    describe "#at" do
      it "returns the translated day of week" do
        job.update!(day_of_week: 1, hour: 2, minute: 3)
        expect(presenter.at).to eq("Monday 02:03")
      end

      context "day of week is not specified" do
        it "returns the hh:mm value only" do
          job.update!(day_of_week: nil, hour: 2, minute: 3)
          expect(presenter.at).to eq("02:03")
        end
      end
    end

    describe "#if_condition" do
      it "returns the translated if_condition" do
        job.update!(if_condition: "first_of_month")
        expect(presenter.if_condition).to eq("first day of the month")
      end

      context "no if_condition exists" do
        it "returns nil" do
          job.update!(if_condition: nil)
          expect(presenter.if_condition).to be_nil
        end
      end
    end

    describe "#last_triggered_at" do
      let(:time) { Time.zone.parse("Jan 01 2017") }

      it "returns the formatted last_triggered_at" do
        job.update!(last_triggered_at: time)

        # Clockface time should be `Pacific Time (US & Canada)`, which is
        # UTC-8 during December/January
        expect(presenter.last_triggered_at).
          to eq("2016-12-31 16:00 <span>PST</span>")
      end

      context "no last_triggered_at exists" do
        it "returns nil" do
          job.update!(last_triggered_at: nil)
          expect(presenter.last_triggered_at).to be_nil
        end
      end
    end
  end
end
