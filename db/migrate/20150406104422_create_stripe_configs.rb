class CreateStripeConfigs < ActiveRecord::Migration
  def change
    create_table :stripe_configs do |t|
      t.string :publishable_key
      t.string :secret_key
      t.string :alias_name
      t.string :merchant_id
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways
      t.timestamps
    end
  end
end
