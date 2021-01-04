class CreateSyClubMembers < ActiveRecord::Migration
  def change
    create_table :sy_club_members do |t|
      t.references :sy_club, index: true
      t.references :sadhak_profile, index: true
      t.integer :status
      t.integer :sy_club_validity_window_id
      t.string :guest_email
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      t.datetime :club_joining_date
      t.timestamps
    end
  end
end
