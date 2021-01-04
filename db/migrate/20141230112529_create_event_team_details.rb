class CreateEventTeamDetails < ActiveRecord::Migration
  def change
    create_table :event_team_details do |t|
      t.integer :team_type
      t.integer :role
      t.string :first_name
      t.string :syid
      t.references :event, index: true
      t.references :sadhak_profile, index: true
      t.foreign_key :events
      t.foreign_key :sadhak_profiles
      

      t.timestamps
    end
  end
end
