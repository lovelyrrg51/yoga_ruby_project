module Api::V1
  class EventCancellationPlanSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
