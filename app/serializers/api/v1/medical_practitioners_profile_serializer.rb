module Api::V1
  class MedicalPractitionersProfileSerializer < ActiveModel::Serializer
    attributes :id, :medical_degree, :practiced_integrative_health_care, :current_professional_role, :other_role, :work_enviroment, :interested_in_panel_discussion, :interested_in_volunteering, :other_speciality
    
    #embed :ids
    has_one :sadhak_profile
    has_one :medical_practitioner_speciality_area, include: true
  end
end
