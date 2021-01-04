class DsProductAssetTagAssociation < ApplicationRecord
  belongs_to :ds_product
  belongs_to :ds_asset_tag
end
