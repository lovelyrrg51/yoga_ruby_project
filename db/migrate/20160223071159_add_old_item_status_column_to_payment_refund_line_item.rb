class AddOldItemStatusColumnToPaymentRefundLineItem < ActiveRecord::Migration
  def change
    add_column :payment_refund_line_items, :old_item_status, :integer
  end
end
