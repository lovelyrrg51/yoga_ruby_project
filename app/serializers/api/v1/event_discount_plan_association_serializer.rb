module Api::V1
  class EventDiscountPlanAssociationSerializer < ActiveModel::Serializer
    attributes :id
    has_one :event
    has_one :discount_plan
  end
end
