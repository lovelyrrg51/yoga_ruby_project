class AddColumnAmountDifferenceToPgSyddTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :pg_sydd_transactions, :amount_difference, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :pg_sydd_transactions, :actual_paid_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
