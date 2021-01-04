class AddTaxDetailsToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :tax_details, :text
  end
end
