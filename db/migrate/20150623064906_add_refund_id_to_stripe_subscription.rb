class AddRefundIdToStripeSubscription < ActiveRecord::Migration
  def change
    add_column :stripe_subscriptions, :refund_id, :string
  end
end
