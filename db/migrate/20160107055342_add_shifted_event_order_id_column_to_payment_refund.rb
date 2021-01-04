class AddShiftedEventOrderIdColumnToPaymentRefund < ActiveRecord::Migration
  def change
    add_column :payment_refunds, :shifted_event_order_id, :integer
    add_index :payment_refunds, :shifted_event_order_id
  end
end
