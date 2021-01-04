module Api::V1
  class EventRegistrationCenterAssociationSerializer < ActiveModel::Serializer
    attributes :id, :event_id, :registration_center_id, :is_cash_payment_allowed
  end
end
