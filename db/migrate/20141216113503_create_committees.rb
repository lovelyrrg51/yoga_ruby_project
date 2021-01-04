class CreateCommittees < ActiveRecord::Migration
  def change
    create_table :committees do |t|
      t.string :name
      t.integer :reporting_committee_id
      t.integer :committee_level
      t.references :sadhak_profile, index: true
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      t.timestamps
    end
  end
end
