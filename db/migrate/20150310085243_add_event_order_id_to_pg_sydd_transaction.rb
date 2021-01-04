class AddEventOrderIdToPgSyddTransaction < ActiveRecord::Migration
  def change
    add_column :pg_sydd_transactions, :event_order_id, :integer
  end
end
