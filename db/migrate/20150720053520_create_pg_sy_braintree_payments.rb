class CreatePgSyBraintreePayments < ActiveRecord::Migration
  def change
    create_table :pg_sy_braintree_payments do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency_iso_code
      t.string :braintree_payment_id
      t.string :refund_ids
      t.string :refunded_transaction_id
      t.integer :status
      t.references :event_order, index: true

      t.timestamps
    end
  end
end
