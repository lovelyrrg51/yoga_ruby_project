module Api::V1
  class EventTypeDigitalAssetAssociationSerializer < ActiveModel::Serializer
    attributes :id, :event_type_id, :digital_asset_id
  end
end
