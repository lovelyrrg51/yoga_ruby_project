FactoryBot.define do
  factory(:sy_club_member_action_detail) do
    action_reason nil
    action_time "2016-08-12T14:18 UTC"
    action_type "transfer"
    from_event_registration_id 127819
    from_status nil
    from_sy_club_member_id 100
    ip nil
    is_deleted false
    requester_id nil
    responder_id nil
    sadhak_profile_id 3134
    status "approved"
    to_event_registration_id 127819
    to_status nil
    to_sy_club_member_id 22671
  end
end
