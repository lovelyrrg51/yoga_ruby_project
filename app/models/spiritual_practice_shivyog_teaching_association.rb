class SpiritualPracticeShivyogTeachingAssociation < ApplicationRecord
  acts_as_paranoid
  belongs_to :spiritual_practice
  belongs_to :shivyog_teaching
end
