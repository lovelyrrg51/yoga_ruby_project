FactoryBot.define do
  factory(:event_type) do
    code nil
    event_meta_type "virtual"
    feedback_form nil
    is_club_activity false
    name "Advanced DSS"
    reference_event_id nil
  end
end
