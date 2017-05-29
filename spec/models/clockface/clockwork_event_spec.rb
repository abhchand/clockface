require "rails_helper"

module Clockface
  RSpec.describe ClockworkEvent, type: :model do
    describe "Associations" do
      it do
        should have_many(:scheduled_jobs).
          class_name("Clockface::ClockworkScheduledJob").
          with_foreign_key("clockface_clockwork_event_id")
      end
    end

    describe "Validations" do
      subject { create(:clockwork_event) }

      describe "name" do
        it { should validate_presence_of(:name) }
        it { should validate_uniqueness_of(:name) }
      end

      describe "command" do
        it { should validate_presence_of(:command) }
      end
    end
  end
end