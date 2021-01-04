class AddItemStatusColumnToPaymentRefund < ActiveRecord::Migration
  def change
    add_column :payment_refunds, :item_status, :integer
  end
end
