FactoryBot.define do
  factory(:payment_gateway_type) do
    config_model_name "PgSyddConfig"
    name "sydd"
    relation_name "pg_sydd_config"
  end
end
