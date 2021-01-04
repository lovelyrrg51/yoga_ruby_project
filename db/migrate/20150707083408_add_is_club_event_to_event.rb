class AddIsClubEventToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_club_event, :boolean, default: :false
  end
end
