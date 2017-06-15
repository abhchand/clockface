module ViewHelpers
  def page
    @page ||= Capybara::Node::Simple.new(rendered)
  end
end
