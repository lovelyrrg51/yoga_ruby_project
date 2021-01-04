FactoryBot.define do
  factory(:event_cost_estimation) do
    budget BigDecimal.new("0.0")
    event_id 3
    name nil
  end
end
