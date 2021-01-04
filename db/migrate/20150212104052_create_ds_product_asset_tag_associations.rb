class CreateDsProductAssetTagAssociations < ActiveRecord::Migration
  def change
    create_table :ds_product_asset_tag_associations do |t|
      t.references :ds_product, index: true
      t.references :ds_asset_tag, index: true
      t.foreign_key :ds_asset_tags
      t.foreign_key :ds_products
      t.timestamps
    end
  end
end
