class CreateStripeSubscriptions < ActiveRecord::Migration
  def change
    create_table :stripe_subscriptions do |t|
      t.string :description
      t.integer :plan
      t.string :card

      t.timestamps
    end
  end
end
