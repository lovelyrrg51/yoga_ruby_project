class AddIsClubActivityToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :is_club_activity, :boolean, default: :false
  end
end
