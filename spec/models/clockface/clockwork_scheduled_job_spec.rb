require "rails_helper"

module Clockface
  RSpec.describe ClockworkScheduledJob, type: :model do
    subject { create(:clockwork_scheduled_job) }

    describe "Associations" do
      it do
        should belong_to(:event).
          class_name("Clockface::ClockworkEvent").
          with_foreign_key("clockface_clockwork_event_id")
      end
    end

    describe "Validations" do
      describe "enabled" do
        it "defaults to false when unspecified" do
          job = create(:clockwork_scheduled_job, enabled: nil)
          expect(job.reload.enabled).to eq(false)
        end
      end

      describe "last_ran_at" do
        it { should allow_value(nil).for(:last_ran_at) }
      end

      describe "period_value" do
        it { should validate_presence_of(:period_value) }
        it { should validate_numericality_of(:period_value).is_greater_than(0) }
      end

      describe "period_units" do
        it { should validate_presence_of(:period_units) }

        it do
          should validate_inclusion_of(:period_units).
            in_array(ClockworkScheduledJob::PERIOD_UNITS)
        end
      end

      describe "day_of_week" do
        it do
          should validate_inclusion_of(:day_of_week).
            in_array((0..6).to_a).
            allow_blank
        end
      end

      describe "hour" do
        it do
          should validate_inclusion_of(:hour).
            in_array((0..23).to_a).
            allow_blank
        end
      end

      describe "minute" do
        it do
          should validate_inclusion_of(:minute).
            in_array((0..59).to_a).
            allow_blank
        end
      end

      describe "timezone" do
        it do
          should validate_inclusion_of(:timezone).
            in_array(ActiveSupport::TimeZone::MAPPING.keys).
            allow_blank
        end
      end

      describe "if_condition" do
        it do
          should validate_inclusion_of(:if_condition).
            in_array(ClockworkScheduledJob::IF_CONDITIONS.keys).
            allow_blank
        end
      end
    end

    describe "#name" do
      it "returns the event's name" do
        expect(subject.name).to eq(subject.event.name)
      end
    end

    describe "#period" do
      it "returns the length of the period in seconds" do
        subject.update(period_value: 1, period_units: "minutes")
        expect(subject.period).to eq(1.minutes)
      end
    end

    describe "#at" do
      it "includes the day of week, hour and minute in the Clockwork format" do
        subject.update(day_of_week: 1, hour: 12, minute: 30)
        expect(subject.at).to eq("Monday 12:30")
      end

      it "left pads the hour and minute" do
        subject.update(day_of_week: 1, hour: 1, minute: 1)
        expect(subject.at).to eq("Monday 01:01")
      end

      context "minute is nil" do
        it "uses the placeholder Clockwork expects" do
          subject.update(day_of_week: 1, hour: 12, minute: nil)
          expect(subject.at).to eq("Monday 12:**")
        end
      end

      context "hour is nil" do
        it "uses the placeholder Clockwork expects" do
          subject.update(day_of_week: 1, hour: nil, minute: 30)
          expect(subject.at).to eq("Monday **:30")
        end
      end

      context "day of week is nil" do
        it "is not included in the string" do
          subject.update(day_of_week: nil, hour: 12, minute: 30)
          expect(subject.at).to eq("12:30")
        end
      end
    end

    context "#if?" do
      context "if_condition is even_week" do
        before(:each) { subject.update(if_condition: "even_week") }

        it "returns true when the week is even numbered" do
          time = Time.parse("Jan 01 2017")
          expect(subject.if?(time)).to be_truthy
        end

        it "returns false when the week is not even numbered" do
          time = Time.parse("Jan 08 2017")
          expect(subject.if?(time)).to be_falsey
        end
      end

      context "if_condition is odd_week" do
        before(:each) { subject.update(if_condition: "odd_week") }

        it "returns true when the week is odd numbered" do
          time = Time.parse("Jan 08 2017")
          expect(subject.if?(time)).to be_truthy
        end

        it "returns false when the week is not odd numbered" do
          time = Time.parse("Jan 01 2017")
          expect(subject.if?(time)).to be_falsey
        end
      end

      context "if_condition is weekday" do
        before(:each) { subject.update(if_condition: "weekday") }

        it "returns true when the day is a weekday" do
          time = Time.parse("Jan 02 2017")
          expect(subject.if?(time)).to be_truthy
        end

        it "returns false when the day is not a weekday" do
          time = Time.parse("Jan 01 2017")
          expect(subject.if?(time)).to be_falsey
        end
      end

      context "if_condition is nil" do
        before(:each) { subject.update(if_condition: nil) }

        it "returns true" do
          expect(subject.if?(Time.now)).to be_truthy
        end
      end
    end
  end
end