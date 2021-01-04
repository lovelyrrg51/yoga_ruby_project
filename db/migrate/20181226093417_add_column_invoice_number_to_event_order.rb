class AddColumnInvoiceNumberToEventOrder < ActiveRecord::Migration[5.1]
  def change
  	unless column_exists? :event_orders, :invoice_number
	  	add_column :event_orders, :invoice_number, :integer
  	end
  end
end
