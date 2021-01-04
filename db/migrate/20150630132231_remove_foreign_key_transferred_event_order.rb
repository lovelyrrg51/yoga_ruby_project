class RemoveForeignKeyTransferredEventOrder < ActiveRecord::Migration
  def change
    remove_foreign_key :transferred_event_orders, name: :transferred_event_orders_parent_event_order_id_fk
  end
end
