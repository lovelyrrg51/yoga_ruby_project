class CreateSyClubVenueDetails < ActiveRecord::Migration
  def change
    create_table :sy_club_venue_details do |t|
      t.integer :venue_type
      t.integer :room_size
      t.integer :windows_count
      t.integer :fans_count
      t.integer :doors_count
      t.string :room_color
      t.string :carpet_type
      t.integer :yantras_count
      t.references :sy_club, index: true
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.timestamps
    end
  end
end
