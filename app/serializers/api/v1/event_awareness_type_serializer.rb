module Api::V1
  class EventAwarenessTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :code
  end
end
