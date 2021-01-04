class AddSyClubToStripeSubscription < ActiveRecord::Migration
  def change
    add_reference :stripe_subscriptions, :sy_club, index: true
  end
end
