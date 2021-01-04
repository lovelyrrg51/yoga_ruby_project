module Api::V1
  class StripeSubscriptionSerializer < ActiveModel::Serializer
    attributes :id, :description, :amount, :status, :charge_id, :created_at, :refund_id
  end
end
