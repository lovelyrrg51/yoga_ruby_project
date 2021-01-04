module Api::V1
  class EventTeamDetailSerializer < ActiveModel::Serializer
    attributes :id, :team_type, :role, :first_name, :syid, :event_id
    #embed :ids
    has_one :sadhak_profile, includes: true
  end
end
