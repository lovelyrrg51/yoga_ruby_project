class CreateTransferredEventOrders < ActiveRecord::Migration
  def change
    create_table :transferred_event_orders do |t|
      t.integer :child_event_order_id
      t.integer :parent_event_order_id
      t.foreign_key :event_orders, column: :parent_event_order_id
      t.timestamps
    end
  end
end
