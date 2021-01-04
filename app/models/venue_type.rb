class VenueType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :events

  scope :venue_type_name, ->(venue_type_name) { where("name ILIKE ?", "%#{venue_type_name}%") }
end
