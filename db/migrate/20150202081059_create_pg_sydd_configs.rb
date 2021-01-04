class CreatePgSyddConfigs < ActiveRecord::Migration
  def change
    create_table :pg_sydd_configs do |t|
      t.string :public_key
      t.string :private_key
      t.references :pg_sydd_merchant, index: true
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways
      t.foreign_key :pg_sydd_merchants
      t.timestamps
    end
  end
end
