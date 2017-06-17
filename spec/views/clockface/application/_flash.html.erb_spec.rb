require "rails_helper"

module Clockface
  RSpec.describe "clockface/application/_flash.html.erb", type: :view do
    it "displays a div for each flash message" do
      flash[:error] = "Some error"
      flash[:notice] = "Some notice"

      render

      expect(page.all(".flash").count).to eq(2)
    end

    it "displays the flash class" do
      flash[:error] = "Some error"

      render

      container = page.find(".flash")
      expect(container[:class]).to include("alert-danger")
    end

    it "displays the message and close button" do
      flash[:error] = "Some error"

      render

      container = page.find(".flash")
      expect(container).to have_content("Some error")
      expect(container.find(".close")).to have_content("x")
    end

    context "message is an array" do
      it "formats the message as a <ul> element" do
        flash[:error] = %w(error1 error2)

        render

        container = page.find(".flash")
        elements = container.all("li")

        expect(elements.size).to eq(2)
        expect(elements[0]).to have_content("error1")
        expect(elements[1]).to have_content("error2")
      end
    end
  end
end
