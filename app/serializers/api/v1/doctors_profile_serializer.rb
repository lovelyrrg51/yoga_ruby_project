module Api::V1
  class DoctorsProfileSerializer < ActiveModel::Serializer
    attributes :id, :medical_school, :education_country_id, :year_of_graduation, :area_of_speciality, :sub_speciality, :license_status, :license_state_id, :license_country_id, :primary_work_setting, :practice_place, :practice_state_id, :practice_country_id, :practice_years, :clinical_research, :hospital_affiliations, :professional_publications, :honors_and_awards
  end
end
