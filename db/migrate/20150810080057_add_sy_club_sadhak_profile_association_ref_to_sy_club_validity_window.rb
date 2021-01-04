class AddSyClubSadhakProfileAssociationRefToSyClubValidityWindow < ActiveRecord::Migration
  def change
    add_column :sy_club_validity_windows, :sy_club_sadhak_profile_association_id, :integer
  end
end
