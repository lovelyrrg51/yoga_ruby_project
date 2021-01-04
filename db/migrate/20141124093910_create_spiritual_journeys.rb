class CreateSpiritualJourneys < ActiveRecord::Migration
  def change
    create_table :spiritual_journeys do |t|
      t.string :source_of_information
      t.text :reason_for_joining
      t.string :first_event_attended
      t.integer :first_event_attended_year
      t.integer :first_event_attended_month
      t.integer :sadhak_profile_id
      
      t.timestamps
    end
  end
end
