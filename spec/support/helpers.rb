Dir[Rails.root.join("spec/support/views/*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.include ViewHelpers, type: :view
end
