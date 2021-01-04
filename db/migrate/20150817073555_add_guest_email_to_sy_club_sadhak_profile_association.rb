class AddGuestEmailToSyClubSadhakProfileAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_sadhak_profile_associations, :guest_email, :string
  end
end
