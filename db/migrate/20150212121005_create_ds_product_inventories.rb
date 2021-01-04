class CreateDsProductInventories < ActiveRecord::Migration
  def change
    create_table :ds_product_inventories do |t|
      t.references :ds_product, index: true
      t.references :ds_shop, index: true
      t.string :quantity
      t.foreign_key :ds_products
      t.foreign_key :ds_shops
      t.timestamps
    end
  end
end
