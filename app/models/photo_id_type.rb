class PhotoIdType < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 },
    uniqueness: { case_sensitive: false }

  scope :photo_id_type_name, ->(photo_id_type_name) { where("name ILIKE ?", "%#{photo_id_type_name}%") }
end
