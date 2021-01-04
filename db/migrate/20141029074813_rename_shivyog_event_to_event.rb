class RenameShivyogEventToEvent < ActiveRecord::Migration
  def change
    rename_table :shivyog_events, :events
  end
end
