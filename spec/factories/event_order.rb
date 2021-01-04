FactoryBot.define do
  factory(:event_order) do
    event_id 10
    final_line_items nil
    gateway_redirect_url nil
    guest_email "vineet@metadesignsolutions.co.uk"
    is_4_eye_verified false
    is_club_order false
    is_deleted false
    is_guest_user false
    order_tax_detail nil
    payment_method "Demand draft"
    reg_ref_number "c92bd831"
    registration_center_id nil
    registration_center_user_id nil
    slug "d810cdfcb040ee1eec88a3e56c14719ca3579dffb1880fd5c8c5a3b93dc30178"
    status "pending"
    sy_club_id nil
    tax_details nil
    total_amount nil
    total_discount nil
    total_tax_details nil
    transaction_id "106305788231"
    user_id 3
  end
end
