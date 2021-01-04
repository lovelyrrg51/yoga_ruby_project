module Api::V1
  class SyClubEventTypeAssociationSerializer < ActiveModel::Serializer
    attributes :id, :status
    
    #embed :ids
    has_one :sy_club
    has_one :event_type
  end
end
