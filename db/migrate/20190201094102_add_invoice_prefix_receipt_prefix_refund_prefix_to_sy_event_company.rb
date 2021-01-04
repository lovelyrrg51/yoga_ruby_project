class AddInvoicePrefixReceiptPrefixRefundPrefixToSyEventCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :sy_event_companies, :invoice_prefix, :string
    add_column :sy_event_companies, :receipt_prefix, :string
    add_column :sy_event_companies, :refund_prefix, :string
  end
end
