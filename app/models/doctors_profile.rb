class DoctorsProfile < ApplicationRecord
  acts_as_paranoid

  PRIMARY_WORK_SETTINGS = %w(Hospital Private)
  REQUIRED_FIELD = [:medical_school, :education_country_id, :year_of_graduation, :area_of_speciality, :sub_speciality, :license_status, :license_state_id, :license_country_id, :primary_work_setting, :practice_place, :practice_state_id, :practice_country_id, :practice_years, :hospital_affiliations, :professional_publications, :honors_and_awards]
  validates :sadhak_profile_id, uniqueness: true
  validates :medical_school, :education_country_id, :year_of_graduation, :area_of_speciality, :sub_speciality, :license_status, :license_state_id, :license_country_id, :primary_work_setting, :practice_place, :practice_state_id, :practice_country_id, :practice_years, :hospital_affiliations, :professional_publications, :honors_and_awards, presence: true
  belongs_to :sadhak_profile
  belongs_to :practice_state, class_name: 'DbState', foreign_key: 'practice_state_id'
  belongs_to :license_state, class_name: 'DbState', foreign_key: 'license_state_id'
  belongs_to :practice_country, class_name: 'DbCountry', foreign_key: 'practice_country_id'
  belongs_to :license_country, class_name: 'DbCountry', foreign_key: 'license_country_id'

  after_initialize { self.clinical_research = false }

  enum license_status: %w(active expired)

end
