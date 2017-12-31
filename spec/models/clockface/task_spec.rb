require "rails_helper"

module Clockface
  RSpec.describe Task, type: :model do
    describe "Associations" do
      it do
        should have_many(:scheduled_jobs).
          class_name("Clockface::ClockworkScheduledJob").
          with_foreign_key("clockface_task_id")
      end
    end

    describe "Validations" do
      subject { create(:task) }

      describe "name" do
        it { should validate_presence_of(:name) }
        it { should validate_uniqueness_of(:name).case_insensitive }
      end

      describe "command" do
        it { should validate_presence_of(:command) }
      end
    end
  end
end
