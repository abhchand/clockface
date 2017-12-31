require "rails_helper"

module Clockface
  RSpec.describe Event, type: :model do
    subject { create(:event) }

    describe "Associations" do
      it do
        should belong_to(:task).
          class_name("Clockface::Task").
          with_foreign_key("clockface_task_id")
      end
    end

    describe "Before Validations" do
      describe "tenant" do
        it "doesn't touch the tenant field" do
          event = build(:event, tenant: nil)
          event.valid?
          expect(event.tenant).to be_nil

          event = build(:event, tenant: "foo")
          event.valid?
          expect(event.tenant).to eq("foo")
        end

        context "multi-tenancy is enabled" do
          before(:each) { enable_multi_tenancy! }

          it "defaults the tenant field only when it is blank" do
            event = build(:event, tenant: nil)
            event.valid?
            expect(event.tenant).to eq(tenant)

            event = build(:event, tenant: "foo")
            event.valid?
            expect(event.tenant).to eq("foo")
          end
        end
      end

      describe "time_zone" do
        it "defaults the time zone to the Clockface time zone if blank" do
          event = build(:event, time_zone: nil)
          event.valid?

          expect(event.time_zone).to eq(clockface_time_zone)
        end
      end
    end

    describe "Validations" do
      describe "tenant" do
        it { should validate_absence_of(:tenant) }

        context "multi-tenancy is enabled" do
          before(:each) { enable_multi_tenancy! }

          subject { create(:event, tenant: tenant) }

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
          event = create(:event, enabled: nil)
          expect(event.reload.enabled).to eq(false)
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
            in_array(Event::PERIOD_UNITS)
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
                    "clockface/event.attributes.day_of_week."\
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
            in_array(Event::IF_CONDITIONS.keys).
            allow_blank
        end
      end
    end

    describe ".find_duplicates_of" do
      let(:event) { subject }
      let(:other_event) { event.dup.tap { |event| event.save } }

      context "another event with the same attributes exists" do
        it "returns the other event" do
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to eq([other_event])
        end
      end

      context "no other event with the same attributes exists" do
        it "returns an empty array when period_value is not the same" do
          event.update(period_value: 2)
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when period_units is not the same" do
          event.update(period_units: "months")
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when day_of_week is not the same" do
          event.update(day_of_week: 3)
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when hour is not the same" do
          event.update(hour: 17)
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when minute is not the same" do
          event.update(minute: 38)
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when time_zone is not the same" do
          event.update(time_zone: "Alaska")
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end

        it "returns an empty array when if_condition is not the same" do
          event.update(if_condition: "even_week")
          expect(
            Clockface::Event.find_duplicates_of(event)
          ).to be_empty
        end
      end
    end

    describe "#name" do
      it "returns the task's name" do
        expect(subject.name).to eq(subject.task.name)
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
