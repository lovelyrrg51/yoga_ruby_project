class EventDigitalAssetAssociation < ApplicationRecord
  belongs_to :event, inverse_of: :event_digital_asset_associations
  belongs_to :digital_asset
end
