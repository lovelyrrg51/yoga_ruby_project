class RenameShivyogEventRegistrationsToEventRegistrations < ActiveRecord::Migration
  def change
    rename_table :shivyog_event_registrations, :event_registrations
  end
end
