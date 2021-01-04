class RegistrationCenterUser < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :registration_center
end
