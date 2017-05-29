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
            in_array(ClockworkScheduledJob::IF_CONDITIONS).
            allow_blank
        end
      end
    end
  end
end
