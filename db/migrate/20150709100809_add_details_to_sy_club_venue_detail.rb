class AddDetailsToSyClubVenueDetail < ActiveRecord::Migration
  def change
    add_column :sy_club_venue_details, :time, :string
    add_column :sy_club_venue_details, :room_other_activities, :string
    add_column :sy_club_venue_details, :painting_in_room, :string
    add_column :sy_club_venue_details, :lighting_arrangement, :string
  end
end
