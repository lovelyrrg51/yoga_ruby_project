class CreateEventPaymentGatewayAssociations < ActiveRecord::Migration
  def change
    create_table :event_payment_gateway_associations do |t|
      t.references :event, index: true
      t.references :payment_gateway, index: true
      t.foreign_key :payment_gateways
      t.foreign_key :events
      t.timestamps
    end
  end
end
