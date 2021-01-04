class AddColumnsToSyEventCompany < ActiveRecord::Migration
  def change
    add_column :sy_event_companies, :llpin_number, :string
    add_column :sy_event_companies, :service_tax_number, :string
    add_column :sy_event_companies, :last_invoice_number, :integer, default: 0
    add_column :sy_event_companies, :terms_and_conditions, :text
    add_column :sy_event_companies, :is_deleted, :boolean, default: false
  end
end
