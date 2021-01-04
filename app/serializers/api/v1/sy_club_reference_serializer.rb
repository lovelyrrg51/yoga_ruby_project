module Api::V1
  class SyClubReferenceSerializer < ActiveModel::Serializer
    attributes :id, :sy_club_id, :sadhak_profile_id, :name
  end
end
