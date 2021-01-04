class RegistrationCenter < ApplicationRecord

  attr_accessor :syid, :first_name

  has_many :event_registration_center_associations, dependent: :destroy
  has_many :events, through: :event_registration_center_associations

  has_many :registration_center_users, dependent: :destroy
  has_many :users, through: :registration_center_users
  has_many :sadhak_profiles, through: :users, source: :sadhak_profile

  scope :registration_center_name, ->(registration_center_name) { where("name ILIKE ?", "%#{registration_center_name}%") }
  scope :registration_center_name, ->(registration_center_name) { where("name ILIKE ?", "%#{registration_center_name}%") }
end
