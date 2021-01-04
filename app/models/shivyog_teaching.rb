class ShivyogTeaching < ApplicationRecord
  has_many :spiritual_practice_shivyog_teaching_associations, dependent: :destroy
  has_many :spiritual_practices, through: :spiritual_practice_shivyog_teaching_associations

  validates_uniqueness_of :name, case_sensitive: false

  scope :shivyog_teaching_name, ->(shivyog_teaching_name) { where("name ILIKE ?", "%#{shivyog_teaching_name}%") }
end
