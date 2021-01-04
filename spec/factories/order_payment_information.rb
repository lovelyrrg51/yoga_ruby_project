FactoryBot.define do
  factory(:order_payment_information) do
    amount BigDecimal.new("1.0")
    billing_address "ToFactory: RubyParser exception parsing this attribute"
    billing_address_city nil
    billing_address_country "India"
    billing_address_postal_code "122001"
    billing_address_state "haryana"
    billing_email "shivam@metadesignsolutions.com"
    billing_name "Charli"
    billing_phone "ToFactory: RubyParser exception parsing this attribute"
    ccavenue_failure_message nil
    ccavenue_payment_mode nil
    ccavenue_status_code nil
    ccavenue_status_identifier nil
    ccavenue_tracking_id nil
    config_id nil
    event_order_id 7
    m_payment_id nil
    status nil
    user_id nil
  end
end
