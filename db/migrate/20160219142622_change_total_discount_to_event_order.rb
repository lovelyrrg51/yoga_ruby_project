class ChangeTotalDiscountToEventOrder < ActiveRecord::Migration
  def change
  	change_column :event_orders, :total_discount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
