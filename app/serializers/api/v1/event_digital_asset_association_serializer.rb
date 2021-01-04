module Api::V1
  class EventDigitalAssetAssociationSerializer < ActiveModel::Serializer
    attributes :id
    has_one :event
    has_one :digital_asset
  end
end
