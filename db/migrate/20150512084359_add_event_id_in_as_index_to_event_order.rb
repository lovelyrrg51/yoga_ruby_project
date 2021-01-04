class AddEventIdInAsIndexToEventOrder < ActiveRecord::Migration
  def change
    add_index :event_orders, :event_id
  end
end
