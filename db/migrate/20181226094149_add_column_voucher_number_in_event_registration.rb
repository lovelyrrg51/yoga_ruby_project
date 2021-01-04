class AddColumnVoucherNumberInEventRegistration < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :event_registrations, :voucher_number
      add_column :event_registrations, :voucher_number, :string
    end
  end
end
