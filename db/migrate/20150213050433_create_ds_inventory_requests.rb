class CreateDsInventoryRequests < ActiveRecord::Migration
  def change
    create_table :ds_inventory_requests do |t|
      t.integer :quantity
      t.references :ds_product, index: true
      t.references :ds_product_inventory_request, index: true
      t.foreign_key :ds_products
      t.foreign_key :ds_product_inventory_requests
      t.timestamps
    end
  end
end
