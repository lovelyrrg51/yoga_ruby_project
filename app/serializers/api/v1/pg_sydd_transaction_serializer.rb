module Api::V1
  class PgSyddTransactionSerializer < ActiveModel::Serializer
    attributes :id, :dd_number, :dd_date, :bank_name, :amount, :additional_details, :is_terms_accepted, :created_at, :event_order_id, :sy_club_id
    #embed :ids
    has_one :pg_sydd_merchant
  end
end
