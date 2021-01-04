class CannonicalEventDigitalAssetAssociation < ApplicationRecord
  belongs_to :digital_asset
  belongs_to :cannonical_event
end
