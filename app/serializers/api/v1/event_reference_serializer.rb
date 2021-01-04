module Api::V1
  class EventReferenceSerializer < ActiveModel::Serializer
    attributes :id, :event_id
    
    #embed :ids
    has_one :sadhak_profile, include: true
  #   has_one :event
  end
end
