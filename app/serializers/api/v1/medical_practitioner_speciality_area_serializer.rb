module Api::V1
  class MedicalPractitionerSpecialityAreaSerializer < ActiveModel::Serializer
    attributes :id, :name
    
  #   #embed :ids
  #   has_many :medical_practitioners_profile
  end
end
