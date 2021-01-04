class AddIndexToLineItem < ActiveRecord::Migration
  def change
    add_index :line_items, :order_id
    add_index :line_items, :digital_asset_id
  end
end
