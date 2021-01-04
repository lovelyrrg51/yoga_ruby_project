class PhysicalExerciseType < ApplicationRecord
  has_many :spiritual_practice_physical_exercise_type_associations, dependent: :destroy
  has_many :spiritual_practices, through: :spiritual_practice_physical_exercise_type_associations

  validates_uniqueness_of :name, case_sensitive: false

  scope :physical_exercise_type_name, ->(physical_exercise_type_name) { where("name ILIKE ?", "%#{physical_exercise_type_name}%") }
end
