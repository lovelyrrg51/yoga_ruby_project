class RemoveColumnInvoiceNumberFromEventOrder < ActiveRecord::Migration[5.1]
  def change
  	if column_exists? :event_orders, :invoice_number
  		remove_column :event_orders, :invoice_number, :integer
  	end
  end
end
