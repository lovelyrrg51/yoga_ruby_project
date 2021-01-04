module Api::V1
  class TicketResponseSerializer < ActiveModel::Serializer
    # attributes :id, :ticket_id, :response, :status, :created_at
    attributes :id, :ticket_id, :response, :created_at
    #embed :ids
    has_one :attachment, include: true
    has_one :user#, include: true
  end
end
