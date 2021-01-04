class AddIndexsToDb < ActiveRecord::Migration[5.2]
  def change
    add_index :advance_profiles, :sadhak_profile_id
    add_index :pg_cash_payment_transactions, :transaction_number
    add_index :pg_sydd_transactions, :dd_number
    add_index :stripe_subscriptions, :card
    add_index :pg_sy_razorpay_payments, :razorpay_payment_id
    add_index :pg_sy_braintree_payments, :braintree_payment_id
    add_index :pg_sy_paypal_payments, :transaction_id
    add_index :order_payment_informations, :ccavenue_tracking_id
    add_index :pg_sy_hdfc_payments, :hdfc_tracking_id
    add_index :pg_sy_payfast_payments, :pf_payment_id
  end
end
