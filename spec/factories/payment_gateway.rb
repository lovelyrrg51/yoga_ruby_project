FactoryBot.define do
  factory(:payment_gateway) do
    payment_gateway_type {PaymentGatewayType.first || association(:payment_gateway_type)}
  end
end
