class CreateSyClubSadhakProfileAssociations < ActiveRecord::Migration
  def change
    create_table :sy_club_sadhak_profile_associations do |t|
      t.references :sadhak_profile, index: true
      t.references :sy_club, index: true
      t.references :sy_club_user_role
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      t.foreign_key :sy_club_user_roles, column: :sy_club_user_role_id
      t.timestamps
    end
  end
end
