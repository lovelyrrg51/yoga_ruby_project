class AddColumnConfigIdToAllPaymentModel < ActiveRecord::Migration[4.2]
  def change
    add_column :stripe_subscriptions, :config_id, :integer
    add_column :pg_sy_razorpay_payments, :config_id, :integer
    add_column :pg_sy_braintree_payments, :config_id, :integer
    add_column :pg_sy_paypal_payments, :config_id, :integer
  end
end
