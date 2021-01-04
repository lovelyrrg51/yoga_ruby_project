FactoryBot.define do
  factory(:order) do
    billing_address nil
    billing_address_city nil
    billing_address_country nil
    billing_address_postal_code nil
    billing_address_state nil
    billing_email nil
    billing_name nil
    billing_phone nil
    ccavenue_customer_identifier nil
    ccavenue_failure_message nil
    ccavenue_payment_mode nil
    ccavenue_status_code nil
    ccavenue_status_message nil
    ccavenue_tracking_id nil
    currency "INR"
    final_line_items nil
    sbm_amount_paid nil
    sbm_merchant_order_num nil
    sbm_order_id nil
    sbm_response nil
    status "cart"
    total_amount BigDecimal.new("0.0")
    user_id 1
  end
end
