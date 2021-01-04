module Api::V1
  class EventPaymentGatewayAssociationSerializer < ActiveModel::Serializer
    attributes :id, :payment_start_date, :payment_end_date
    #embed :ids
    has_one :event
    has_one :payment_gateway
  end
end
