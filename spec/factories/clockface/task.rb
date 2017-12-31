FactoryGirl.define do
  factory :task, :class => "Clockface::Task" do
    sequence(:name) { |n| "Name #{n}" }
    description nil
    sequence(:command) { |n| "Command #{n}" }
  end
end
