class AddTransactionIdAndPaymentMethosToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :transaction_id, :string
    add_column :event_orders, :payment_method, :string
  end
end
