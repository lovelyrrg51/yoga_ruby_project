class CreatePgSyPayfastConfigs < ActiveRecord::Migration
  def change
    create_table :pg_sy_payfast_configs do |t|
      t.string :user_name
      t.string :alias_name
      t.string :merchant_id
      t.string :merchant_key
      t.references :payment_gateway, index: true
      t.integer :pdt
      t.string :pdt_key
      t.integer :country_id
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0.0
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
