class AddTotalTaxDetailsAndOrderTaxDetailColumnsToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :order_tax_detail, :text
    add_column :event_orders, :total_tax_details, :text
  end
end
