module Api::V1
  class EventRegistrationSerializer < ActiveModel::Serializer
    attributes :id, :event_id, :status, :event_seating_category_association_id, :is_extra_seat, :has_attended, :expires_at
    
    #embed :ids
    has_one :event_order, serializer: EventRegistrationsEventOrderDataSerializer, include: true
    
    has_one :sadhak_profile, serializer: EventRegistrationSadhakProfileSerializer, include: true
  
  end
end
