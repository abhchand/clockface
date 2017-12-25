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
      self[:time_zone] = nil if self[:time_zone].blank?
      self[:if_condition] = nil if self[:if_condition].blank?
      default_tenant_if_needed
    end

    validates :period_value, presence: true, numericality: { greater_than: 0 }
    validates :period_units, presence: true, inclusion: PERIOD_UNITS
    validates :day_of_week, inclusion: { in: 0..6 }, allow_nil: true
    validates :hour, inclusion: { in: 0..23 }, allow_nil: true
    validates :minute, inclusion: { in: 0..59 }, allow_nil: true
    validates :time_zone, inclusion: ActiveSupport::TimeZone::MAPPING.keys, allow_nil: true
    validates :if_condition, inclusion: IF_CONDITIONS.keys, allow_nil: true

    with_options if: proc { clockface_multi_tenancy_enabled? } do |x|
      x.validate :tenant_is_valid
    end

    with_options if: proc { !clockface_multi_tenancy_enabled? } do |x|
      x.validates :tenant, absence: true
    end

    validate :day_of_week_must_have_timestamp

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
        time_zone: job.time_zone,
        if_condition: job.if_condition
      ).where.not(id: job.id)
    end

    def period
      # e.g. period_value: 2, period_units: weeks
      #  => 2.weeks
      period_value.send(period_units.to_sym)
    end
    # Note: Clockwork refers to this value as the period internally, but
    # `sync_database_events` expects this model to respond to `:frequency`
    # Keep consistent with internal language by using period, but add alias
    # for compatibility.
    # It's also extra confusing since in most fields (e.g. Physics) the words
    # 'period' and 'frequency' are inverses of each other... oh well.
    alias_method :frequency, :period

    def at
      return nil if self[:hour].nil? && self[:minute].nil?

      [
        at_formatted_day_of_week,
        [at_formatted_hour, at_formatted_minute].join(":")
      ].compact.join(" ")
    end

    def tz
      # Active Support stores a mapping between human readable and IANA time
      # zones. These mappings can be found in `ActiveSupport::TimeZone::MAPPING`
      #
      # e.g.
      #
      #  "Chennai"    =>  "Asia/Kolkata"
      #  "Kathmandu"  =>  "Asia/Kathmandu"
      #  "Tokyo"      =>  "Asia/Tokyo"
      #
      # Since multiple human names can point to the same IANA time zone, we
      # store the human readable name in the underlying `time_zone` DB field
      #
      # The Clockwork API dictates that the model must respond to `:tz` and
      # return the IANA name (See `Clockwork::Event#convert_timezone`), so we
      # convert the value using ActiveSupport Mapping first
      #
      ActiveSupport::TimeZone::MAPPING[self[:time_zone]]
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

    def ignored_attributes
      # Every time Clockwork reloads the models from the database it compares
      # the before/after attributes to see if the model `has_changed?`. If any
      # attributes have been changed, it reloads the event.
      # The Clockwork API lets us selectively ignore some fields in this
      # attribute comparison.
      # Exclude `last_triggered_at` and `updated_at` since they will always change
      # each run
      [ :last_triggered_at, :updated_at ]
    end

    private

    def default_tenant_if_needed
      if clockface_multi_tenancy_enabled? && self[:tenant].blank?
        self[:tenant] = clockface_current_tenant
      end
    end

    def tenant_is_valid
      if self[:tenant] != clockface_current_tenant
        errors.add(
          :tenant,
          I18n.t(
            "activerecord.errors.models.clockface/clockwork_scheduled_job."\
              "attributes.tenant.invalid"
          )
        )
      end
    end

    def day_of_week_must_have_timestamp
      if self[:hour].nil? && self[:minute].nil? && !self[:day_of_week].nil?
        errors.add(
          :day_of_week,
          I18n.t(
            "activerecord.errors.models.clockface/clockwork_scheduled_job."\
              "attributes.day_of_week.day_of_week_must_have_timestamp"
          )
        )
      end
    end

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
