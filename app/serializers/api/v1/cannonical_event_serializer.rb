module Api::V1
  class CannonicalEventSerializer < ActiveModel::Serializer
    attributes :id, :event_name, :event_meta_type
    #embed :ids
    has_many :prerequisite_cannonical_events
    has_many :digital_assets
    # has_many :events
  end
end
