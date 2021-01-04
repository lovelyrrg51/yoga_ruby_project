class AddColumnToStripeSubscription < ActiveRecord::Migration
  def change
    add_reference :stripe_subscriptions, :event_order, index: true
    add_column :stripe_subscriptions, :token, :string
    add_column :stripe_subscriptions, :customer_id, :string
    add_column :stripe_subscriptions, :amount, :decimal, precision: 10,
    scale: 2
    add_column :stripe_subscriptions, :status, :integer
    add_column :stripe_subscriptions, :email, :string
  end
end
