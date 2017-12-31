module Clockface
  class Task < ApplicationRecord
    has_many(
      :events,
      foreign_key: "clockface_task_id",
      class_name: "Clockface::Event"
    )

    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :command, presence: true
  end
end
