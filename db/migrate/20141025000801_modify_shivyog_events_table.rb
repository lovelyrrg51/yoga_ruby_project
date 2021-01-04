class ModifyShivyogEventsTable < ActiveRecord::Migration
  def change
    remove_column :shivyog_events, :event_location_type
    remove_column :shivyog_events, :event_location
    remove_column :shivyog_events, :event_content_type
    remove_column :shivyog_events, :organizer_user_id
    add_column :shivyog_events, :address_id, :integer    # venue
    add_column :shivyog_events, :cannonical_event_id, :integer
    add_column :shivyog_events, :event_proposal_id, :integer
    add_column :shivyog_events, :daily_start_time, :datetime
    add_column :shivyog_events, :daily_end_time, :datetime
    add_column :shivyog_events, :description, :text
  end
end
