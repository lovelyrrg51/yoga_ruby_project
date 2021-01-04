class AddColumnIsDeletedToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :is_deleted, :boolean, default: false
  end
end
