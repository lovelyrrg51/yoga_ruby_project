FactoryBot.define do
  factory(:payment_mode) do
    name "credit card"
    shortcode "cc"
    group_name "credit_card"
    deleted_at nil
  end
end
