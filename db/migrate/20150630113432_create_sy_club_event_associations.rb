class CreateSyClubEventAssociations < ActiveRecord::Migration
  def change
    create_table :sy_club_event_associations do |t|
      t.references :event, index: true
      t.references :sy_club, index: true
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.foreign_key :events, column: :event_id
      t.timestamps
    end
  end
end
