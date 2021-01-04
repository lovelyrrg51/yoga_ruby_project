module Api::V1
  class PgSyPaypalPaymentSerializer < ActiveModel::Serializer
    attributes :id, :amount, :event_order_id, :status, :transaction_id, :currency_code, :created_at, :sy_club_id#, :invoice_number, :token, :redirect_url
    
  end
end
