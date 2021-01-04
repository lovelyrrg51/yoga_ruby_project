FactoryBot.define do
  factory(:pg_sy_payfast_payment) do
    amount BigDecimal.new("8.44")
    amount_fee BigDecimal.new("-1.56")
    amount_gross BigDecimal.new("10.0")
    amount_net BigDecimal.new("8.44")
    config_id 1
    currency "ZAR"
    email_address "jayyagnik@gmail.com"
    event_order_id 55220
    is_deleted false
    item_description "ToFactory: RubyParser exception parsing this attribute"
    m_payment_id "ToFactory: RubyParser exception parsing this attribute"
    name_first "Jay"
    name_last "Yagnik"
    pf_payment_id "5257892"
    processed true
    signature "ToFactory: RubyParser exception parsing this attribute"
    status "success"
    sy_club_id nil
  end
end
