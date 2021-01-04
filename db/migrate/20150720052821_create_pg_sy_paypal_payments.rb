class CreatePgSyPaypalPayments < ActiveRecord::Migration
  def change
    create_table :pg_sy_paypal_payments do |t|
      t.integer :amount
      t.integer :event_order_id
      t.integer :status
      t.string :transaction_id
      t.string :invoice_number
      t.string :token
      t.string :redirect_url

      t.timestamps
    end
  end
end
