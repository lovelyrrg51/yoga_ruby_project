module Api::V1
  class UserTicketGroupAssociationSerializer < ActiveModel::Serializer
    attributes :id, :ticket_group_id, :user_id
  end
end
