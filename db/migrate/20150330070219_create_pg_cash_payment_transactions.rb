class CreatePgCashPaymentTransactions < ActiveRecord::Migration
  def change
    create_table :pg_cash_payment_transactions do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.integer :status
      t.date :payment_date
      t.boolean :is_terms_accepted, default: :false
      t.text :additional_details
      t.string :transaction_number
      t.references :event_order, index: true

      t.timestamps
    end
  end
end
