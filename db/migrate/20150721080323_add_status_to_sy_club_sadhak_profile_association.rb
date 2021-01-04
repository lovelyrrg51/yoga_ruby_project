class AddStatusToSyClubSadhakProfileAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_sadhak_profile_associations, :status, :integer
  end
end
