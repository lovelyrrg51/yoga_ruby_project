module Api::V1
  class EventRegistrationSadhakProfileSerializer < ActiveModel::Serializer
    attributes :id, :syid, :first_name
  
    #embed :ids
    has_one :professional_detail, include: true
  end
end
