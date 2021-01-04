FactoryBot.define do
  factory(:stripe_subscription) do
    amount BigDecimal.new("1500.0")
    card "tok_15pd2fA5oqTefGXm2ENMsXJE"
    charge_id nil
    config_id nil
    customer_id "cus_61gPzIZzfL2tve"
    description "Rails Stripe customer"
    email nil
    event_order_id 112
    plan nil
    refund_id nil
    status "success"
    sy_club_id nil
  end
end
