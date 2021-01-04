class RemoveColumnTokenFromStripeSubscription < ActiveRecord::Migration
  def change
    remove_column :stripe_subscriptions, :token
  end
end
