class CreateEventReferences < ActiveRecord::Migration
  def change
    create_table :event_references do |t|
      t.references :sadhak_profile, index: true
      t.references :event, index: true
      t.foreign_key :events, dependent: :delete
      t.foreign_key :sadhak_profiles, dependent: :delete
      t.timestamps
    end
  end
end
