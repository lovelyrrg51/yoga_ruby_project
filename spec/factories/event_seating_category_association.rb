FactoryBot.define do
  factory(:event_seating_category_association) do
    cancellation_charge nil
    event_id 4
    is_deleted false
    price BigDecimal.new("1000.0")
    seating_capacity nil
    seating_category_id 1
  end
end
