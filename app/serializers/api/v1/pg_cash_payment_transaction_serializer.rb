module Api::V1
  class PgCashPaymentTransactionSerializer < ActiveModel::Serializer
    attributes :id, :amount, :status, :payment_date, :is_terms_accepted, :additional_details, :transaction_number, :created_at, :sy_club_id
    #embed :ids
    has_one :event_order
  end
end
