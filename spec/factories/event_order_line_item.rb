FactoryBot.define do
  factory(:event_order_line_item) do
    available_for_seva false
    deleted_at nil
    discount nil
    event_order_id 1
    event_seating_category_association_id 4
    event_type_pricing_id nil
    is_deleted false
    is_extra_seat false
    price BigDecimal.new("10000.0")
    registration_number nil
    sadhak_profile_id 1
    seating_category_id nil
    status "success"
    tax_details nil
    tax_types []
    total_tax_detail nil
    transferred_ref_number nil
  end
end
