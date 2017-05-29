FactoryGirl.define do
  factory :clockwork_scheduled_job, :class => "Clockface::ClockworkScheduledJob" do
    association :event, factory: :clockwork_event
    enabled true
    last_ran_at nil
    period_value 1
    period_units "hours"
    day_of_week 0
    hour 12
    minute 0
    timezone "UTC"
    if_condition nil
  end
end