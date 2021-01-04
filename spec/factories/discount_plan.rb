FactoryBot.define do
  factory(:discount_plan) do
    discount_amount BigDecimal.new("10.0")
    discount_type "percentage"
    is_delete false
    name "TestDiscountPlan"
    user_id 122
  end
end
