module Api::V1
  class PurchasedDigitalAssetSerializer < ActiveModel::Serializer
    attributes :user_id, :digital_asset_id
  end
end
