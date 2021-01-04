module Api::V1
  class SyClubMemberSerializer < ActiveModel::Serializer
    attributes :id, :status, :virtual_role, :expiration_date
    
    #embed :ids
    has_one :sadhak_profile
    has_one :sy_club
  end
end
