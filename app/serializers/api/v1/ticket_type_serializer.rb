module Api::V1
  class TicketTypeSerializer < ActiveModel::Serializer
    attributes :id, :ticket_type, :ticket_group_id
  end
end
