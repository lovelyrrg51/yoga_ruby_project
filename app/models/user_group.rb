class UserGroup < ApplicationRecord
  has_many :user_group_mappings
  has_many :users, through: :user_group_mappings
  has_many :asset_group_mappings
  has_many :digital_assets, through: :asset_group_mappings
end
