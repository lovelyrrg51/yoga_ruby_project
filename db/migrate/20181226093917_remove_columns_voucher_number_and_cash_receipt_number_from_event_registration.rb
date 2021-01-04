class RemoveColumnsVoucherNumberAndCashReceiptNumberFromEventRegistration < ActiveRecord::Migration[5.1]
  def change
    if column_exists? :event_registrations, :cash_receipt_number
      remove_column :event_registrations, :cash_receipt_number
    end
    if column_exists? :event_registrations, :voucher_number
      # remove_column :event_registrations, :voucher_number
    end
  end
end
