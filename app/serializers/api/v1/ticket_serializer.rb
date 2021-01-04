module Api::V1
  class TicketSerializer < ActiveModel::Serializer
    attributes :id, :title, :description, :created_at, :ticketable_type, :ticketable_id
    #embed :ids
  #   has_one :ticketable
    has_many :ticket_responses#, include: true
    has_one :user#, include: true
  #   has_many :ticket_groups
  end
end
