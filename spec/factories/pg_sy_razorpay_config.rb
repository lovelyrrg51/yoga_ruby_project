FactoryBot.define do
  factory(:pg_sy_razorpay_config) do
    publishable_key nil
    secret_key nil
    alias_name nil
    merchant_id nil
    country_id nil
    tax_amount 500
    payment_gateway {PaymentGateway.first || association(:payment_gateway)}
  end
end
