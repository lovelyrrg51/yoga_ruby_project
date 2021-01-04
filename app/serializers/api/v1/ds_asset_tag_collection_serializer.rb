module Api::V1
  class DsAssetTagCollectionSerializer < ActiveModel::Serializer
    attributes :id, :name
    #embed :ids
    has_one :ds_asset_tag
  end
end
