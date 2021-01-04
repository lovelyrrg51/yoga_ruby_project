module Api::V1
  class PaymentGatewaySerializer < ActiveModel::Serializer
    attributes :id
    #embed :ids
    has_one :payment_gateway_type
    has_one :pg_sydd_config, include: true
    has_one :ccavenue_config, include: true
    has_one :stripe_config, include: true
    has_one :pg_sy_razorpay_config, include: true
    has_one :pg_sy_braintree_config, include: true
    has_one :pg_sy_paypal_config, include: true
    has_one :pg_sy_payfast_config, include: true
  end
end
