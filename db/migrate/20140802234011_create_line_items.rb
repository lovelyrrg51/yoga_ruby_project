class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :digital_asset_id
      t.decimal :total_price
      t.timestamps
    end
  end
end
