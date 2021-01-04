class Profession < ApplicationRecord
  has_many :professional_details

  validates_uniqueness_of :name, case_sensitive: false

  scope :profession_name, ->(profession_name) { where("name ILIKE ?", "%#{profession_name}%") }
end
