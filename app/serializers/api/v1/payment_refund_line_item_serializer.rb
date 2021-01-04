module Api::V1
  class PaymentRefundLineItemSerializer < ActiveModel::Serializer
    attributes :id, :status, :sadhak_profile_id, :event_registration_id, :event_id, :event_seating_category_association_id, :payment_refund_id, :event_order_line_item_id
  end
end
