class PurchasedDigitalAsset < ApplicationRecord
  belongs_to :user
  belongs_to :digital_asset
end
