class RemoveAmountDifferenceColumnsFromDdAndCashModles < ActiveRecord::Migration[5.1]
  def change
    remove_column :pg_sydd_transactions, :amount_difference
    remove_column :pg_sydd_transactions, :actual_paid_amount
    remove_column :pg_cash_payment_transactions, :amount_difference
    remove_column :pg_cash_payment_transactions, :actual_paid_amount
  end
end
