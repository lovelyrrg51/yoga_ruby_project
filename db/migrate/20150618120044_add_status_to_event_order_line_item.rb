class AddStatusToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :status, :integer
  end
end
