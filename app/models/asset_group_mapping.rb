class AssetGroupMapping < ApplicationRecord
  belongs_to :digital_asset
  belongs_to :user_group
end
