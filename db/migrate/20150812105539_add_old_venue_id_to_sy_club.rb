class AddOldVenueIdToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :old_venue_id, :integer
  end
end
