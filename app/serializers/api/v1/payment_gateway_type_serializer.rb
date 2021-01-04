module Api::V1
  class PaymentGatewayTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :config_model_name, :relation_name
    #embed :ids
    
    has_many :payment_gateways#, include: true
  end
end
