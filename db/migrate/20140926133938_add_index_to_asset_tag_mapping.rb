class AddIndexToAssetTagMapping < ActiveRecord::Migration
  def change
    add_index :asset_tag_mappings, :digital_asset_id
    add_index :asset_tag_mappings, :asset_tag_id
  end
end
