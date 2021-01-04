class CreateShivyogJourneys < ActiveRecord::Migration
  def change
    create_table :shivyog_journeys do |t|
      t.string :source_of_information
      t.string :tv_channels # Not clear what mutltiple choice to provide
      t.string :reason_for_joining
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
