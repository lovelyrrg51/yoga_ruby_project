module Api::V1
  class ProfessionalDetailSerializer < ActiveModel::Serializer
    attributes :id, :highest_degree, :occupation, :designation, :industry, :profession_id, :area_of_specialization, :other_profession, :name_of_organization, :years_of_experience, :personal_interests, :hobbies, :sadhak_profile_id, :professional_specialization
  end
end
