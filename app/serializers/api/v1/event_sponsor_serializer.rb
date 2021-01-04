module Api::V1
  class EventSponsorSerializer < ActiveModel::Serializer
    attributes :id, :remarks
    
    #embed :ids
    has_one :sadhak_profile, include: true
    has_one :event
  end
end
