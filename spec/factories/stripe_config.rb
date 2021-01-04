FactoryBot.define do
  factory(:stripe_config) do
    alias_name "ShivYog Forum Final Production Gateway"
    country_id 254
    merchant_id "10"
    payment_gateway_id 2
    publishable_key "pk_live_oR1SCold4cPYkJuNsnyM4us6"
    secret_key "sk_live_EZvDie6UnaqjkKb63UKFLJzz"
    tax_amount 0.0
  end
end
