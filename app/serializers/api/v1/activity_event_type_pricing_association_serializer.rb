module Api::V1
  class ActivityEventTypePricingAssociationSerializer < ActiveModel::Serializer
    attributes :id, :event_id, :event_type_pricing_id
    # has_one :event
    # has_one :event_type_pricing
  end
end
