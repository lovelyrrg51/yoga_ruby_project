FactoryBot.define do
  factory(:payment_refund) do
    action "cancellation"
    amount_refunded BigDecimal.new("0.0")
    cancellation_charges BigDecimal.new("0.0")
    event_cancellation_plan_id nil
    event_id 568
    event_order_id 31583
    ip "ToFactory: RubyParser exception parsing this attribute"
    is_deleted false
    item_status nil
    max_refundable_amount BigDecimal.new("10.0")
    policy_refundable_amount BigDecimal.new("10.0")
    request_object({"event_id" => "568", "event_order_id" => "31583", "method" => "Ccavenue Payment", "transaction_id" => "105036027174", "reg_ref_number" => "ToFactory: RubyParser exception parsing this attribute", "sadhak_profiles" => [{"syid" => "80250", "firstName" => "sandeep", "event_seating_category_association_id" => "135", "event_order_line_item_id" => "94574", "touched_columns" => []}], "amount" => 10, "is_transfer" => false})
    requester_id 3
    responder_id nil
    shifted_event_order_id nil
    status "requested"
  end
end
