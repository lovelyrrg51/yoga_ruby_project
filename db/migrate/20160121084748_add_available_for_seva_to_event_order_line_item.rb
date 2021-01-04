class AddAvailableForSevaToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :available_for_seva, :boolean, default: :false
  end
end
