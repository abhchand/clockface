module Clockface
  class ApplicationRecord < ActiveRecord::Base
    include Clockface::ConfigHelper

    self.abstract_class = true
  end
end
