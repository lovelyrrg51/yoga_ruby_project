module Api::V1
  class EventTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :event_meta_type, :is_club_activity, :feedback_form, :reference_event_id
    
    #embed :ids
    has_many :digital_assets
    has_many :event_type_pricings
  end
end
