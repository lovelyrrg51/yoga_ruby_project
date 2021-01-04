class AddPaymentStartDateAndPaymentEndDateToEventPaymentGatewayAssociation < ActiveRecord::Migration
  def change
    add_column :event_payment_gateway_associations, :payment_start_date, :date
    add_column :event_payment_gateway_associations, :payment_end_date, :date
  end
end
