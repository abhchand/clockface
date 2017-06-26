module Clockface
  class ClockworkScheduledJob < ApplicationRecord
    extend Forwardable

    PERIOD_UNITS = %w(seconds minutes hours days weeks months years).freeze
    IF_CONDITIONS = {
      "even_week" => lambda { |time| (time.strftime("%W").to_i % 2) == 0 },
      "odd_week" => lambda { |time| (time.strftime("%W").to_i % 2) == 1 },
      "weekday" => lambda { |time| (time.strftime("%a")[0] != "S") },
      "first_of_month" => lambda { |time| time.strftime("%-d").to_i == 1 },
      "last_of_month" => lambda { |time| (time + 1.day).strftime("%-d").to_i == 1 },
    }.freeze

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
    validates :if_condition, inclusion: IF_CONDITIONS.keys, allow_nil: true

    def_delegators :event,
      :name,
      :description,
      :command

    def self.find_duplicates_of(job)
      Clockface::ClockworkScheduledJob.where(
        period_value: job.period_value,
        period_units: job.period_units,
        day_of_week: job.day_of_week,
        hour: job.hour,
        minute: job.minute,
        timezone: job.timezone,
        if_condition: job.if_condition
      ).where.not(id: job.id)
    end

    def period
      # e.g. period_value: 2, period_units: weeks
      #  => 2.weeks
      period_value.send(period_units.to_sym)
    end

    def at
      return nil if self[:hour].nil? && self[:minute].nil?

      [
        at_formatted_day_of_week,
        [at_formatted_hour, at_formatted_minute].join(":")
      ].compact.join(" ")
    end

    def tz
      self[:timezone]
    end

    def tz=(tz)
      self[:timezone] = tz
    end

    def if?(time)
      if self[:if_condition].present?
        IF_CONDITIONS[self[:if_condition]].call(time)
      else
        true
      end
    end

    def if=(if_condition)
      self[:if_condition] = if_condition
    end

    private

    def at_formatted_day_of_week
      Date::DAYNAMES[self[:day_of_week]] if self[:day_of_week].present?
    end

    def at_formatted_hour
      self[:hour].present? ? self[:hour].to_s.rjust(2, "0") : "**"
    end

    def at_formatted_minute
      self[:minute].present? ? self[:minute].to_s.rjust(2, "0") : "**"
    end
  end
end
