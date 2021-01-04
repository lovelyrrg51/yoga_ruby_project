FactoryBot.define do
  factory(:ticket) do
    assigned_user_id nil
    closed_at nil
    description nil
    priority nil
    reopened_at nil
    status "open"
    ticket_cc nil
    ticket_type_id nil
    ticketable_id 3
    ticketable_type "Event"
    title "New Event DSS Shivir"
    user_id 1
  end
end
