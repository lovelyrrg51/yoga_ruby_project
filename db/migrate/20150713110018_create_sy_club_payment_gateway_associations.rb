class CreateSyClubPaymentGatewayAssociations < ActiveRecord::Migration
  def change
    create_table :sy_club_payment_gateway_associations do |t|
      t.references :sy_club
      t.references :payment_gateway
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.foreign_key :payment_gateways, column: :payment_gateway_id
      t.timestamps
    end
  end
end
