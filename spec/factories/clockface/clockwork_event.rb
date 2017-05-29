FactoryGirl.define do
  factory :clockwork_event, :class => "Clockface::ClockworkEvent" do
    sequence(:name) { |n| "Name #{n}" }
    description nil
    sequence(:command) { |n| "Command #{n}" }
  end
end
