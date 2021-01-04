class AssetTag < ApplicationRecord
  belongs_to :digital_asset
  belongs_to :tag_collection
  has_many :asset_tag_mappings
  has_many :digital_assets, through: :asset_tag_mappings
end
