class AddIsDeletedColumnToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :is_deleted, :boolean, default: false
  end
end
