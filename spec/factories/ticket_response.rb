FactoryBot.define do
  factory(:ticket_response) do
    response "Okay"
    status "waiting_for_response"
    ticket_id 16
    user_id 35
  end
end
