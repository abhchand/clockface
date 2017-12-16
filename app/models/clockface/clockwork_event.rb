module Clockface
  class ClockworkEvent < ApplicationRecord
    has_many(
      :scheduled_jobs,
      foreign_key: "clockface_clockwork_event_id",
      class_name: "Clockface::ClockworkScheduledJob"
    )

    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :command, presence: true
  end
end
