class MedicalPractitionerSpecialityArea < ApplicationRecord
  has_many :medical_practitioners_profile

  validates_uniqueness_of :name, case_sensitive: false

  scope :medical_practitioner_speciality_area_name, ->(medical_practitioner_speciality_area_name) { where("name ILIKE ?", "%#{medical_practitioner_speciality_area_name}%") }
end
