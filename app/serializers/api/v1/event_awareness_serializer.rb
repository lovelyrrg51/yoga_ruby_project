module Api::V1
  class EventAwarenessSerializer < ActiveModel::Serializer
    attributes :id, :event_awareness_type_id, :event_id, :budget, :event_awareness_type_name
    #embed :ids
    has_one :event_awareness_type, include: true
  end
end
