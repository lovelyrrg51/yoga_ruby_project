class SpiritualPracticePhysicalExerciseTypeAssociation < ApplicationRecord
  acts_as_paranoid

  belongs_to :spiritual_practice
  belongs_to :physical_exercise_type
end
