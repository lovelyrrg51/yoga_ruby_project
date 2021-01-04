FactoryBot.define do
  factory(:event_registration_center_association) do
    event_id 20
    is_cash_payment_allowed false
    registration_center_id 2
  end
end
