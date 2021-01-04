FactoryBot.define do
  factory(:payment_gateway_mode_association) do
    percent 0.0
    percent_type 0
    payment_gateway {PaymentGateway.first || association(:payment_gateway)}
    payment_mode {PaymentMode.first || association(:payment_mode)}
    deleted_at nil
  end
end
