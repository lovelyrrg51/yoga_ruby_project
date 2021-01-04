module Api::V1
  class EventPrerequisitesEventTypeSerializer < ActiveModel::Serializer
    attributes :id, :event_id, :event_type_id
  end
end
