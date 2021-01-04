class AddColumnEventOrderLineItemIdToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :event_order_line_item_id, :integer
  end
end
