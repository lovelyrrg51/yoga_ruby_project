class AddHasAttendedToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :has_attended, :boolean, default: true
  end
end
