module Api::V1
  class PgSyPayfastPaymentSerializer < ActiveModel::Serializer
    attributes :id, :name_first, :name_last, :email_address, :amount, :item_description, :status, :pf_payment_id, :currency_code, :event_order_id
  end
end
