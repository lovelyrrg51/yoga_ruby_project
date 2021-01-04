class CreatePgSyPaypalConfigs < ActiveRecord::Migration
  def change
    create_table :pg_sy_paypal_configs do |t|
      t.string :username
      t.string :password
      t.string :signature
      t.integer :country_id
      t.float :tax_amount
      t.string :alias_name
      t.string :publishable_key
      t.string :secret_key
      t.integer :merchant_id
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways, column: :payment_gateway_id

      t.timestamps
    end
  end
end
