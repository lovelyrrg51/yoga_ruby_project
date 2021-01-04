class AddDeatilsToPgSyRazorpayPayments < ActiveRecord::Migration
  def change
    add_column :pg_sy_razorpay_payments, :razorpay_payment_id, :string
    add_column :pg_sy_razorpay_payments, :refund_id, :string
    remove_column :pg_sy_razorpay_payments, :amount, :integer
    remove_column :pg_sy_razorpay_payments, :amount_refunded, :string
    remove_column :pg_sy_razorpay_payments, :status, :string
    add_column :pg_sy_razorpay_payments, :amount, :decimal, precision: 10, scale: 2
    add_column :pg_sy_razorpay_payments, :amount_refunded, :decimal, precision: 10, scale: 2
    add_column :pg_sy_razorpay_payments, :status, :integer
  end
end