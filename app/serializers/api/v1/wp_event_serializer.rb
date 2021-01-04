module Api::V1
  class WpEventSerializer < ActiveModel::Serializer
    attributes :id, :event_name, :event_location, :event_name_with_location, :entity_type, :event_start_date, :event_end_date, :end_date_ignored, :status
  end
end
