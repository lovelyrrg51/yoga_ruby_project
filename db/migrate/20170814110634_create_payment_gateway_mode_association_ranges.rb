class CreatePaymentGatewayModeAssociationRanges < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_gateway_mode_association_ranges do |t|
      t.float :min_value, default: 0
      t.float :max_value, default: Float::INFINITY
      t.float :percent, default: 0
      t.references :payment_gateway_mode_association, index: { name: 'index_pg_mode_ass_id_to_ranges' }
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :payment_gateway_mode_association_ranges, :deleted_at
  end
end
