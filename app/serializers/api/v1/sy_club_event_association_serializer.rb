module Api::V1
  class SyClubEventAssociationSerializer < ActiveModel::Serializer
    attributes :id
    has_one :event
    has_one :sy_club
  end
end
