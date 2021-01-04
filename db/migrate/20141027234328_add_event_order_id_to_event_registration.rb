class AddEventOrderIdToEventRegistration < ActiveRecord::Migration
  def change
    add_column :shivyog_event_registrations, :event_order_id, :integer
  end
end
