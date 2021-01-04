module Api::V1
  class WpEventTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :event_meta_type
  end
end
