class AddTaxDetailsAndTotalTaxDetailColumnsToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :tax_details, :text
    add_column :event_order_line_items, :total_tax_detail, :text
  end
end
