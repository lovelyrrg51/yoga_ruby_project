module Api::V1
  class SyClubMemberActionDetailSerializer < ActiveModel::Serializer
    attributes :id, :action, :from_sy_club_member_id, :to_sy_club_member_id, :from_event_registration_id, :to_event_registration_id, :reason, :requester_id, :approver_id, :action_time, :status
  end
end
