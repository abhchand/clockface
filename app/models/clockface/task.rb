module Clockface
  class Task < ApplicationRecord
    has_many(
      :scheduled_jobs,
      foreign_key: "clockface_task_id",
      class_name: "Clockface::ClockworkScheduledJob"
    )

    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :command, presence: true
  end
end
