class AddColumnToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :discount, :decimal, precision: 10, scale: 2
  end
end
