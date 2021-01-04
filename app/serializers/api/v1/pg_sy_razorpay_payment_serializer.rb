module Api::V1
  class PgSyRazorpayPaymentSerializer < ActiveModel::Serializer
    attributes :id, :entity, :amount, :currency, :status, :description, :refund_status, :amount_refunded, :notes, :pg_sy_razorpay_merchant_id, :razorpay_payment_id, :refund_id, :event_order_id, :created_at, :sy_club_id
  end
end
