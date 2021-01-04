FactoryBot.define do
  factory(:pg_cash_payment_transaction) do
    additional_details "test"
    amount BigDecimal.new("2.28")
    event_order_id 78
    is_terms_accepted true
    payment_date "2015-03-10"
    status "pending"
    sy_club_id nil
    transaction_number "136"
  end
end
