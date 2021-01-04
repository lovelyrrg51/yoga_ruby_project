class AddIndexToAssetTag < ActiveRecord::Migration
  def change
    add_index :asset_tags, :digital_asset_id
    add_index :asset_tags, :tag_collection_id
  end
end
