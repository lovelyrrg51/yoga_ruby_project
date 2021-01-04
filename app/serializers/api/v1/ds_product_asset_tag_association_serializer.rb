module Api::V1
  class DsProductAssetTagAssociationSerializer < ActiveModel::Serializer
    attributes :id
    has_one :ds_product
    has_one :ds_asset_tag
  end
end
