FactoryBot.define do
  factory(:pg_sy_braintree_config) do
    alias_name "BrainTree Malaysia Production Account"
    country_id 149
    merchant_id "ppz6tjw2vfk3vscw"
    payment_gateway {PaymentGateway.first || association(:payment_gateway)}
    publishable_key "mwbn6ztdqfk9z7sk"
    secret_key "ToFactory: RubyParser exception parsing this attribute"
    tax_amount 4.4
  end
end
