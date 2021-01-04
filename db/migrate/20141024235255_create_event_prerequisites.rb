class CreateEventPrerequisites < ActiveRecord::Migration
  def change
    create_table :event_prerequisites do |t|
      t.integer :cannonical_event_id
      t.integer :prerequisite_cannonical_event_id
      t.timestamps
    end
  end
end
