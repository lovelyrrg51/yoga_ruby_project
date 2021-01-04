FactoryBot.define do
  factory(:pg_sy_braintree_payment) do
    amount BigDecimal.new("574.2")
    braintree_payment_id "ToFactory: RubyParser exception parsing this attribute"
    config_id nil
    currency_iso_code "MYR"
    event_order_id 3917
    refund_ids "[]"
    refunded_transaction_id nil
    status "failure"
    sy_club_id nil
  end
end
