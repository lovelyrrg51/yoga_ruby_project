class CreateDsProductInventoryRequests < ActiveRecord::Migration
  def change
    create_table :ds_product_inventory_requests do |t|
      t.references :ds_shop, index: true
      t.foreign_key :ds_shops
      t.timestamps
    end
  end
end
