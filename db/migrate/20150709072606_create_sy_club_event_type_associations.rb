class CreateSyClubEventTypeAssociations < ActiveRecord::Migration
  def change
    create_table :sy_club_event_type_associations do |t|
      t.references :sy_club
      t.references :event_type
      t.foreign_key :event_types, column: :event_type_id
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.timestamps
    end
  end
end
