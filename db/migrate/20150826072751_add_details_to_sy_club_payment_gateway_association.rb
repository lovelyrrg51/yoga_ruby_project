class AddDetailsToSyClubPaymentGatewayAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_payment_gateway_associations, :payment_start_date, :date
    add_column :sy_club_payment_gateway_associations, :payment_end_date, :date
  end
end
