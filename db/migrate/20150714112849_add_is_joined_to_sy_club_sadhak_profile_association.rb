class AddIsJoinedToSyClubSadhakProfileAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_sadhak_profile_associations, :is_joined, :boolean, :default  => :false
  end
end
