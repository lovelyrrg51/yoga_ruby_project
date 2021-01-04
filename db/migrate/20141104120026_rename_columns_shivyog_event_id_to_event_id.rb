class RenameColumnsShivyogEventIdToEventId < ActiveRecord::Migration
  def change
    rename_column :event_orders, :shivyog_event_id, :event_id
    rename_column :event_registrations, :shivyog_event_id, :event_id
    rename_column :event_seating_category_associations, :shivyog_event_id, :event_id
    rename_column :historical_events, :shivyog_event_id, :event_id
  end
end
