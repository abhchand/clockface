module Clockface
  class ApplicationRecord < ActiveRecord::Base
    include Clockface::ClockfaceConfigHelper

    self.abstract_class = true
  end
end
