FactoryBot.define do
  factory(:pg_sy_payfast_config) do
    alias_name "Payfast Live Account"
    country_id 224
    is_deleted false
    merchant_id "10040462"
    merchant_key "ToFactory: RubyParser exception parsing this attribute"
    payment_gateway_id 44
    pdt "disabled"
    pdt_key nil
    tax_amount BigDecimal.new("0.0")
    user_name "drnileshnaik@yahoo.com"
  end
end
