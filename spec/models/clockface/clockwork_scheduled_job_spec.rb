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

    describe "Before Validations" do
      describe "tenant" do
        it "doesn't touch the tenant field" do
          job = build(:clockwork_scheduled_job, tenant: nil)
          job.valid?
          expect(job.tenant).to be_nil

          job = build(:clockwork_scheduled_job, tenant: "foo")
          job.valid?
          expect(job.tenant).to eq("foo")
        end

        context "multi-tenancy is enabled" do
          before(:each) { enable_multi_tenancy! }

          it "defaults the tenant field only when it is blank" do
            job = build(:clockwork_scheduled_job, tenant: nil)
            job.valid?
            expect(job.tenant).to eq(tenant)

            job = build(:clockwork_scheduled_job, tenant: "foo")
            job.valid?
            expect(job.tenant).to eq("foo")
          end
        end
      end

      describe "time_zone" do
        it "defaults the time zone to the Clockface time zone if blank" do
          job = build(:clockwork_scheduled_job, time_zone: nil)
          job.valid?

          expect(job.time_zone).to eq(clockface_time_zone)
        end
      end
    end

    describe "Validations" do
      describe "tenant" do
        it { should validate_absence_of(:tenant) }

        context "multi-tenancy is enabled" do
          before(:each) { enable_multi_tenancy! }

          subject { create(:clockwork_scheduled_job, tenant: tenant) }

          it do
            should allow_value(tenant).for(:tenant)
            should_not allow_value("foo").for(:tenant)

            # The `before_validation` hook will update the tenant since it is
            # nil and this test will incorrectly pass. To bypass that, bypass
            # the whole validation hook
            allow(subject).to receive(:default_tenant_if_needed)
            should_not allow_value(nil).for(:tenant)
          end
        end
      end

      describe "enabled" do
        it "defaults to false when unspecified" do
          job = create(:clockwork_scheduled_job, enabled: nil)
          expect(job.reload.enabled).to eq(false)
        end
      end

      describe "last_triggered_at" do
        it { should allow_value(nil).for(:last_triggered_at) }
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

        describe "day_of_week_must_have_timestamp" do
          context "day_of_week is present but hour and minute are nil" do
            it "should fail validation" do
              subject.day_of_week = 1
              subject.hour = nil
              subject.minute = nil

              expect(subject.valid?).to be_falsey

              error = subject.errors.messages[:day_of_week].first
              expect(error).to eq(
                t(
                  "activerecord.errors.models."\
                    "clockface/clockwork_scheduled_job.attributes.day_of_week."\
                    "day_of_week_must_have_timestamp"
                )
              )
            end
          end
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

      describe "time_zone" do
        it do
          should validate_inclusion_of(:time_zone).
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

    describe ".find_duplicates_of" do
      let(:job) { subject }
      let(:other_job) { job.dup.tap { |job| job.save } }

      context "another job with the same attributes exists" do
        it "returns the other job" do
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to eq([other_job])
        end
      end

      context "no other job with the same attributes exists" do
        it "returns an empty array when period_value is not the same" do
          job.update(period_value: 2)
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when period_units is not the same" do
          job.update(period_units: "months")
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when day_of_week is not the same" do
          job.update(day_of_week: 3)
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when hour is not the same" do
          job.update(hour: 17)
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when minute is not the same" do
          job.update(minute: 38)
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when time_zone is not the same" do
          job.update(time_zone: "Alaska")
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
        end

        it "returns an empty array when if_condition is not the same" do
          job.update(if_condition: "even_week")
          expect(
            Clockface::ClockworkScheduledJob.find_duplicates_of(job)
          ).to be_empty
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

      it "responds to :frequency as an alias" do
        subject.update(period_value: 1, period_units: "minutes")
        expect(subject.frequency).to eq(1.minutes)
      end
    end

    describe "#at" do
      it "left pads the hour and minute" do
        subject.update(day_of_week: nil, hour: 1, minute: 1)
        expect(subject.at).to eq("01:01")
      end

      context "day of week is not present" do
        it "returns the formatted string" do
          subject.update(day_of_week: nil, hour: 12, minute: 30)
          expect(subject.at).to eq("12:30")
        end

        context "minute is nil" do
          it "uses the '**' placeholder Clockwork expects" do
            subject.update(day_of_week: nil, hour: 12, minute: nil)
            expect(subject.at).to eq("12:**")
          end
        end

        context "hour is nil" do
          it "uses the '**' placeholder Clockwork expects" do
            subject.update(day_of_week: nil, hour: nil, minute: 30)
            expect(subject.at).to eq("**:30")
          end
        end

        context "both minute and hour are nil" do
          it "returns nil" do
            subject.update(day_of_week: nil, hour: nil, minute: nil)
            expect(subject.at).to be_nil
          end
        end
      end

      context "day of week is present" do
        it "returns the formatted string" do
          subject.update(day_of_week: 1, hour: 12, minute: 30)
          expect(subject.at).to eq("Monday 12:30")
        end

        context "minute is nil" do
          it "uses the '**' placeholder Clockwork expects" do
            subject.update(day_of_week: 1, hour: 12, minute: nil)
            expect(subject.at).to eq("Monday 12:**")
          end
        end

        context "hour is nil" do
          it "uses the '**' placeholder Clockwork expects" do
            subject.update(day_of_week: 1, hour: nil, minute: 30)
            expect(subject.at).to eq("Monday **:30")
          end
        end

        context "both minute and hour are nil" do
          it "returns nil" do
            subject.update(day_of_week: 1, hour: nil, minute: nil)
            expect(subject.at).to be_nil
          end
        end
      end
    end

    describe "#tz" do
      it "returns the IANA time zone" do
        subject.update(time_zone: "Pacific Time (US & Canada)")
        expect(subject.tz).to eq("America/Los_Angeles")
      end
    end

    describe "#if?" do
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

      context "if_condition is first_of_month" do
        before(:each) { subject.update(if_condition: "first_of_month") }

        it "returns true when the day is a the first of the month" do
          time = Time.parse("Jan 01 2017")
          expect(subject.if?(time)).to be_truthy
        end

        it "returns false when the day is not a the first of the month" do
          time = Time.parse("Jan 02 2017")
          expect(subject.if?(time)).to be_falsey
        end
      end

      context "if_condition is last_of_month" do
        before(:each) { subject.update(if_condition: "last_of_month") }

        it "returns true when the day is the last of the month" do
          time = Time.parse("Jan 31 2017")
          expect(subject.if?(time)).to be_truthy
        end

        it "returns false when the day is not the last of the month" do
          time = Time.parse("Jan 30 2017")
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
