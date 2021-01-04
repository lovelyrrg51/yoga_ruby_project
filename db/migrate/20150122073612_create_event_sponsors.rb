class CreateEventSponsors < ActiveRecord::Migration
  def change
    create_table :event_sponsors do |t|
      t.references :sadhak_profile, index: true
      t.references :event, index: true
      t.text :remarks
      t.foreign_key :events, dependent: :delete
      t.foreign_key :sadhak_profiles, dependent: :delete

      t.timestamps
    end
  end
end
