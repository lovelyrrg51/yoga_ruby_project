class AddEventOrderLineItemRefernceToPaymentRefundLineItem < ActiveRecord::Migration
  def change
    add_reference :payment_refund_line_items, :event_order_line_item, index: true
  end
end
