class AddInvoiceNumberAndSerialNumberToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :invoice_number, :string
    add_column :event_registrations, :serial_number, :integer
    add_reference :event_registrations, :sy_event_company, index: true
  end
end
