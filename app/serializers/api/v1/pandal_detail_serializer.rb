module Api::V1
  class PandalDetailSerializer < ActiveModel::Serializer
    attributes :id, :len, :width, :seating_type, :matresses_count, :chairs_count, :arrangement_details, :event_id
  end
end
