class AssetTagMapping < ApplicationRecord
  belongs_to :digital_asset
  belongs_to :asset_tag
end
