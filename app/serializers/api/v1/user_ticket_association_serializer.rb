module Api::V1
  class UserTicketAssociationSerializer < ActiveModel::Serializer
    attributes :id, :ticket_id, :user_id
  end
end
