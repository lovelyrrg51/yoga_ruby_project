class AddStatusToDsProductInventoryRequest < ActiveRecord::Migration
  def change
    add_column :ds_product_inventory_requests, :status, :integer
  end
end
