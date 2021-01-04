class CreatePaymentGateways < ActiveRecord::Migration
  def change
    create_table :payment_gateways do |t|
      t.references :payment_gateway_type, index: true
      t.foreign_key :payment_gateway_types
      t.timestamps
    end
  end
end
