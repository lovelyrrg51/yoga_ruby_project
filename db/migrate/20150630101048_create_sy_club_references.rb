class CreateSyClubReferences < ActiveRecord::Migration
  def change
    create_table :sy_club_references do |t|
      t.references :sy_club, index: true
      t.references :sadhak_profile, index: true
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.timestamps
    end
  end
end
