class User < ApplicationRecord
  ROLES = %i[read read_write].map(&:to_s).freeze

  validates :role, inclusion: ROLES, allow_nil: true

  before_save :lower_email_case

  private

  def lower_email_case
    email.downcase!
  end
end
