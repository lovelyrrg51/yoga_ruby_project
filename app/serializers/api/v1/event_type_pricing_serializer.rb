module Api::V1
  class EventTypePricingSerializer < ActiveModel::Serializer
    attributes :id, :name, :price, :tier_type, :event_type_id
  end
end
