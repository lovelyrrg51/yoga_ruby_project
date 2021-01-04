module Api::V1
  class TransactionLogSerializer < ActiveModel::Serializer
    attributes :id, :transaction_loggable_id, :transaction_loggable_type, :gateway_request_object, :gateway_response_object, :transaction_type, :gateway_transaction_id, :other_detail, :gateway_type, :gateway_name, :status
  end
end
