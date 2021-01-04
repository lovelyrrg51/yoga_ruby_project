class CreatePgSyRazorpayPayments < ActiveRecord::Migration
  def change
    create_table :pg_sy_razorpay_payments do |t|
      t.string :entity
      t.integer :amount
      t.string :currency
      t.string :status
      t.string :description
      t.string :refund_status
      t.string :amount_refunded
      t.string :notes
      t.integer :pg_sy_razorpay_merchant_id

      t.timestamps
    end
  end
end
