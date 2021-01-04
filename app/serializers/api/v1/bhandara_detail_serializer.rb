module Api::V1
  class BhandaraDetailSerializer < ActiveModel::Serializer
    attributes :id, :budget, :event_id
    
    #embed :ids
    has_many :bhandara_items, include: true
    
  end
end
