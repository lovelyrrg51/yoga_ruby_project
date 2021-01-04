class AddTaxTypeIdsToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :tax_types, :text
  end
end
