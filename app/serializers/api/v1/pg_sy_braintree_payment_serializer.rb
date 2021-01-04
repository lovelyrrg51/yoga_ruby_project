module Api::V1
  class PgSyBraintreePaymentSerializer < ActiveModel::Serializer
    attributes :id, :amount, :currency_iso_code, :braintree_payment_id, :refund_ids, :refunded_transaction_id, :status, :created_at, :sy_club_id
    #embed :ids
    has_one :event_order
    
    def refund_ids
      unless object.refund_ids.empty?
        object.refund_ids.scan(/\w+/)
      else
        nil
      end
    end
  end
end
