FactoryBot.define do
  factory(:transaction_log) do
    gateway_name "stripe"
    gateway_request_object({"customer" => "cus_6wKoyZl5iewyI6", "amount" => 5000, "description" => "Shivyog Registration", "currency" => "usd", "metadata" => {"transaction_log_id" => "1", "email" => "rajeshbhagtani51@gmai.com"}})
    gateway_response_object({"id" => "ch_16iS8dDddDExZeOmXSAZzJk0", "object" => "charge", "created" => 1441641995, "livemode" => true, "paid" => true, "status" => "succeeded", "amount" => 5000, "currency" => "usd", "refunded" => false, "source" => {"id" => "card_16iS8IDddDExZeOmv4owVBHr", "object" => "card", "last4" => "6727", "brand" => "Visa", "funding" => "credit", "exp_month" => 4, "exp_year" => 2016, "fingerprint" => "cKctp4RVuwtumzLl", "country" => "IN", "name" => "Manohar Bhai Mehta", "address_line1" => "ToFactory: RubyParser exception parsing this attribute", "address_line2" => "Gol Bazar, Jabalpur", "address_city" => "Jabalpur", "address_state" => "Madhya Pradesh", "address_zip" => "482002", "address_country" => "India", "cvc_check" => "pass", "address_line1_check" => "unavailable", "address_zip_check" => "unavailable", "tokenization_method" => nil, "dynamic_last4" => nil, "metadata" => {}, "customer" => "cus_6wKoyZl5iewyI6"}, "captured" => true, "balance_transaction" => "txn_16iS8eDddDExZeOmOGDxZhgg", "failure_message" => nil, "failure_code" => nil, "amount_refunded" => 0, "customer" => "cus_6wKoyZl5iewyI6", "invoice" => nil, "description" => "Shivyog Registration", "dispute" => nil, "metadata" => {"transaction_log_id" => "1", "email" => "rajeshbhagtani51@gmai.com"}, "statement_descriptor" => nil, "fraud_details" => {}, "receipt_email" => nil, "receipt_number" => nil, "shipping" => nil, "destination" => nil, "application_fee" => nil, "refunds" => {"object" => "list", "total_count" => 0, "has_more" => false, "url" => "ToFactory: RubyParser exception parsing this attribute", "data" => []}})
    gateway_transaction_id "ch_16iS8dDddDExZeOmXSAZzJk0"
    gateway_type "online"
    ip nil
    other_detail({"amount" => 50, "sy_club_id" => "622", "association_ids" => [7296], "guest_email" => "rajeshbhagtani51@gmai.com", "sadhak_profile_ids" => [40068]})
    request_params nil
    status "success"
    sy_pg_id nil
    transaction_loggable_id 622
    transaction_loggable_type "SyClub"
    transaction_type "pay"
    user_id nil
  end
end
