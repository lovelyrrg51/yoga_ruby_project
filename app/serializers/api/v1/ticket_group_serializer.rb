module Api::V1
  class TicketGroupSerializer < ActiveModel::Serializer
    attributes :id, :name
    #embed :ids
    has_many :users, include: true
  end
end
