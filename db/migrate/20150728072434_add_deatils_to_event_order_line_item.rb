class AddDeatilsToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :is_extra_seat, :boolean, default: false
  end
end
