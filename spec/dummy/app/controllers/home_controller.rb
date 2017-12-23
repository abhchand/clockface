class HomeController < ApplicationController
  def index
    render plain: "Welcome to tenant #{tenant}"
  end
end
