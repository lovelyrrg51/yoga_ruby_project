class HdfcConfig < ActiveRecord::Migration[5.1]
  def change
    create_table :hdfc_configs do |t|
      t.string :alias_name
      t.string :working_key
      t.string :merchant_id
      t.string :access_code
      t.integer :payment_gateway_id
      t.integer :country_id
      t.float :tax_amount
    end
  end
end
