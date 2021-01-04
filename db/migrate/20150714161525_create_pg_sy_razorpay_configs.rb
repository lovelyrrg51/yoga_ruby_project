class CreatePgSyRazorpayConfigs < ActiveRecord::Migration
  def change
    create_table :pg_sy_razorpay_configs do |t|
      t.string :publishable_key
      t.string :secret_key
      t.string :alias_name
      t.string :merchant_id
      t.integer :country_id
      t.float :tax_amount
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways
      t.timestamps
    end
  end
end
