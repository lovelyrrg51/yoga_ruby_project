class CreatePaymentGatewayModeAssociationTaxTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_gateway_mode_association_tax_types do |t|
      t.references :tax_type, index: true
      t.references :payment_gateway_mode_association, index: { name: 'index_pg_mode_ass_tax_types_on_pg_mode_ass_id' }
      t.float :percent, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :payment_gateway_mode_association_tax_types, :deleted_at
  end
end
