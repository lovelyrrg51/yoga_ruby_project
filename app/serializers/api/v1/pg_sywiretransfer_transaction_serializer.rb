module Api::V1
  class PgSywiretransferTransactionSerializer < ActiveModel::Serializer
    attributes :id, :date_of_transaction, :amount, :bank_reference_id, :remitters_bank_details, :beneficiary_bank_details, :currency
    has_one :pg_sywiretransfer_merchants
  end
end
