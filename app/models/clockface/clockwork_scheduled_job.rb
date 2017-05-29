module Clockface
  class ClockworkScheduledJob < ApplicationRecord
    IF_CONDITIONS = %w(odd_week even_week weekday)
    PERIOD_UNITS = %w(seconds minutes hours days weeks months years)

    belongs_to(
      :event,
      foreign_key: "clockface_clockwork_event_id",
      class_name: "Clockface::ClockworkEvent"
    )

    before_validation do
      self[:enabled] = false if self[:enabled].nil?
      self[:timezone] = nil if self[:timezone].blank?
      self[:if_condition] = nil if self[:if_condition].blank?
    end

    validates :period_value, presence: true, numericality: { greater_than: 0 }
    validates :period_units, presence: true, inclusion: PERIOD_UNITS
    validates :day_of_week, inclusion: { in: 0..6 }, allow_nil: true
    validates :hour, inclusion: { in: 0..23 }, allow_nil: true
    validates :minute, inclusion: { in: 0..59 }, allow_nil: true
    validates :timezone, inclusion: ActiveSupport::TimeZone::MAPPING.keys, allow_nil: true
    validates :if_condition, inclusion: IF_CONDITIONS, allow_nil: true
  end
end
