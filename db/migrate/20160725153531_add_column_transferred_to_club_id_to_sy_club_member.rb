class AddColumnTransferredToClubIdToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :transferred_to_club_id, :integer
  end
end
