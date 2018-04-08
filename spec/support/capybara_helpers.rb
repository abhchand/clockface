module CapybaraHelpers
  # This helper *shouldn't* be necessary because Capybara provides
  #   select("value", from: "form_element_name")
  #
  # For some very frustrating reason, that randomly seems to fail to
  # find the dropdown and value on a page even though it clearly exists on
  # the page.
  #
  # The workaround is this tiny helper which uses the `#select_option` method
  def select_option(element_name, value)
    find("select[name='#{element_name}']").all("option").each do |option|
      next unless option["value"] == value.to_s || option.text == value.to_s

      option.select_option
      # rubocop:disable Lint/NonLocalExitFromIterator
      return
      # rubocop:enable Lint/NonLocalExitFromIterator
    end
  end
end
