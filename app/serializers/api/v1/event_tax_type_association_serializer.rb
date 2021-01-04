module Api::V1
  class EventTaxTypeAssociationSerializer < ActiveModel::Serializer
    attributes :id, :percent, :sequence
    
    #embed :ids
    has_one :event
    has_one :tax_type, include: true
  end
end
