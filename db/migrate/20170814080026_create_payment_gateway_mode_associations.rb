class CreatePaymentGatewayModeAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_gateway_mode_associations do |t|
      t.float :percent, default: 0
      t.integer :percent_type
      t.references :payment_gateway, index: true
      t.references :payment_mode, index: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :payment_gateway_mode_associations, :deleted_at
  end
end
