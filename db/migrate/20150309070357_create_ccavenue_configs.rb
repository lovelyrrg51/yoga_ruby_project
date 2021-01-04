class CreateCcavenueConfigs < ActiveRecord::Migration
  def change
    create_table :ccavenue_configs do |t|
      t.string :alias_name
      t.string :working_key
      t.string :merchant_id
      t.string :access_code
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways

      t.timestamps
    end
  end
end
