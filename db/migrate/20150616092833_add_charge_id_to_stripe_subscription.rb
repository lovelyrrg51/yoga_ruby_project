class AddChargeIdToStripeSubscription < ActiveRecord::Migration
  def change
    add_column :stripe_subscriptions, :charge_id, :string
  end
end
