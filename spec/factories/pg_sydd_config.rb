FactoryBot.define do
  factory(:pg_sydd_config) do
    alias_name nil
    country_id nil
    payment_gateway_id nil
    pg_sydd_merchant_id 1
    private_key "test"
    public_key "test"
    tax_amount nil
  end
end
