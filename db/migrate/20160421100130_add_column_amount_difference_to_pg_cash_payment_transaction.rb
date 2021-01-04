class AddColumnAmountDifferenceToPgCashPaymentTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :pg_cash_payment_transactions, :amount_difference, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :pg_cash_payment_transactions, :actual_paid_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
