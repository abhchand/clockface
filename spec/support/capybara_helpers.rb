module CapybaraHelpers
  # This helper *shouldn't* be necessary because Capybara provides
  #   select("value", from: "form_element_name")
  #
  # For some reason that's very frustrating, that randomly seems to fail to
  # find the dropdown and value on a page even though it clearly exists on
  # the page.
  #
  # The workaround is this tiny helper which uses the `#select_option` method
  def select_option(element_name, value)
    find("select[name='#{element_name}']").all("option").each do |option|
      if option["value"] == value.to_s || option.text == value.to_s
        option.select_option
        return
      end
    end
  end
end
