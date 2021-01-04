class AddForeignKeysToAssetGroupMapping < ActiveRecord::Migration
  def change
    add_foreign_key :asset_group_mappings, :digital_assets, :column => :digital_asset_id
    add_foreign_key :asset_group_mappings, :user_groups, :column => :user_group_id
  end
end
