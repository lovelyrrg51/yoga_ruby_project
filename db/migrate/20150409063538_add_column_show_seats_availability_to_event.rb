class AddColumnShowSeatsAvailabilityToEvent < ActiveRecord::Migration
  def change
    add_column :events, :show_seats_availability, :boolean, default: false
    
  end
end
