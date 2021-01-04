class AddAutomaticInvoiceColumnToSyEventCompany < ActiveRecord::Migration
  def change
    add_column :sy_event_companies, :automatic_invoice, :boolean, default: false
  end
end
