FactoryBot.define do
  factory(:event_cancellation_plan_item) do
    amount BigDecimal.new("500.0")
    amount_type "fixed"
    days_before 15
    event_cancellation_plan_id 2
    is_deleted false
  end
end
