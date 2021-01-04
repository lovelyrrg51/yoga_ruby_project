FactoryBot.define do
  factory(:payment_gateway_mode_association_tax_type) do
    tax_type {TaxType.first || association(:tax_type)}
    payment_gateway_mode_association {PaymentGatewayModeAssociation.first || association(:payment_gateway_mode_association)}
    percent 52.5
    deleted_at nil
  end
end
