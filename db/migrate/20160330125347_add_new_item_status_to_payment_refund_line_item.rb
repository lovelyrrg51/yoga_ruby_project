class AddNewItemStatusToPaymentRefundLineItem < ActiveRecord::Migration
  def change
    add_column :payment_refund_line_items, :new_item_status, :integer
  end
end
