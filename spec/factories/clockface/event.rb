FactoryGirl.define do
  factory :event, class: "Clockface::Event" do
    association :task, factory: :task
    enabled true
    last_triggered_at nil
    period_value 1
    period_units "hours"
    day_of_week 0
    hour 12
    minute 0
    time_zone "UTC"
    if_condition nil
  end
end
