class AddVenueTypeToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :venue_type, index: true
  end
end
