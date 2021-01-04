class ChangeColumnDiscountToEventOrderLineItem < ActiveRecord::Migration
  def change
  	change_column :event_order_line_items, :discount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
