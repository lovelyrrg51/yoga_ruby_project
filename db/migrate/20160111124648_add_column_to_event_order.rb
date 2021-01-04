class AddColumnToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :total_discount, :decimal, precision: 10, scale: 2
  end
end
