class AddDsAssetTagIdToDsInventoryRequest < ActiveRecord::Migration
  def change
    add_column :ds_inventory_requests, :ds_asset_tag_id, :integer
  end
end
