FactoryBot.define do
  factory(:pg_sydd_transaction) do
    additional_details "test description"
    amount BigDecimal.new("12000.0")
    bank_name "State bank of india"
    dd_date "2015-03-24"
    dd_number "abcdd1"
    event_order_id nil
    is_terms_accepted true
    pg_sydd_merchant_id nil
    status "pending"
    sy_club_id nil
  end
end
