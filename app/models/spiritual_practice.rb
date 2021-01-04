class SpiritualPractice < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = []

  validates :sadhak_profile_id, uniqueness: true
  belongs_to :sadhak_profile

  has_many :spiritual_practice_frequent_sadhna_type_associations, dependent: :destroy
  has_many :frequent_sadhna_types, through: :spiritual_practice_frequent_sadhna_type_associations

  has_many :spiritual_practice_physical_exercise_type_associations, dependent: :destroy
  has_many :physical_exercise_types, through: :spiritual_practice_physical_exercise_type_associations

  has_many :spiritual_practice_shivyog_teaching_associations, dependent: :destroy
  has_many :shivyog_teachings, through: :spiritual_practice_shivyog_teaching_associations

  enum sadhana_frequency_days_per_week: {
    daily: 0,
    weekly: 1,
    monthly: 2,
    only_during_shivir: 3
  }

  after_save { self.sadhak_profile.check_profile_completeness }

  accepts_nested_attributes_for :frequent_sadhna_types
  accepts_nested_attributes_for :physical_exercise_types
  accepts_nested_attributes_for :shivyog_teachings
end
