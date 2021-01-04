class RenameVoucherColumnsInSyEventCompany < ActiveRecord::Migration[5.1]
  def change

    unless column_exists? :sy_event_companies, :last_receipt_voucher_number
      add_column :sy_event_companies, :last_receipt_voucher_number, :integer, default: 0
    end

    if column_exists? :sy_event_companies, :last_cash_receipt_number
      unless column_exists? :sy_event_companies, :last_invoice_voucher_number
        rename_column :sy_event_companies, :last_cash_receipt_number, :last_invoice_voucher_number
      end
    else
      unless column_exists? :sy_event_companies, :last_invoice_voucher_number
        add_column :sy_event_companies, :last_invoice_voucher_number, :integer, default: 0
      end
    end

    if column_exists? :sy_event_companies, :last_voucher_number
      unless column_exists? :sy_event_companies, :last_refund_voucher_number
        rename_column :sy_event_companies, :last_voucher_number, :last_refund_voucher_number
      end
    else
      unless column_exists? :sy_event_companies, :last_refund_voucher_number
        add_column :sy_event_companies, :last_refund_voucher_number, :integer, default: 0
      end
    end
  end
end
