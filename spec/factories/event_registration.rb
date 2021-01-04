FactoryBot.define do
  factory(:event_registration) do
    deleted_at nil
    event_id 0
    event_order_id nil
    event_order_line_item_id nil
    event_seating_category_association_id nil
    event_type_pricing_id nil
    expires_at nil
    has_attended true
    invoice_number nil
    is_deleted false
    is_extra_seat false
    renewed_from nil
    sadhak_profile_id 0
    serial_number nil
    special_considerations nil
    status "transferred"
    sy_event_company_id nil
    user_id nil
    voucher_number nil
  end
end
