class AddDsAssetTagIdToDsProduct < ActiveRecord::Migration
  def change
    add_reference :ds_products, :ds_asset_tag, index: true
  end
end
