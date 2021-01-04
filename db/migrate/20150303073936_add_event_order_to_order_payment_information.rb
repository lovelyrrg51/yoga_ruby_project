class AddEventOrderToOrderPaymentInformation < ActiveRecord::Migration
  def change
    add_reference :order_payment_informations, :event_order, index: true
  end
end
