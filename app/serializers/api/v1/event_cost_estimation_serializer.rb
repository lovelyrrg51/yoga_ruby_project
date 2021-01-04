module Api::V1
  class EventCostEstimationSerializer < ActiveModel::Serializer
    attributes :id, :name, :budget, :event_id
  end
end
