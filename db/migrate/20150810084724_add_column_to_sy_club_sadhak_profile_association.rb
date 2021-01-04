class AddColumnToSyClubSadhakProfileAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_sadhak_profile_associations, :club_joining_date, :datetime
    add_column :sy_club_sadhak_profile_associations, :sy_club_validity_window_id, :integer
  end
end
