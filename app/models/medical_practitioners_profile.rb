class MedicalPractitionersProfile < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [:medical_degree, :current_professional_role, :work_enviroment]

  validates :sadhak_profile_id, uniqueness: true, on: :create

  belongs_to :sadhak_profile
  belongs_to :medical_practitioner_speciality_area

  enum current_professional_role: {
    physician: 0,
    therapist: 1,
    health_care_extender: 2,
    medical_student: 3,
    other: 4
  }

  enum work_enviroment: {
    academia: 0,
    administrator: 1,
    goverment_regular: 2,
    medical_director: 3,
    private_practice: 4,
    research: 5,
    retired_physican: 6,
    employed_physican: 7
  }
end
