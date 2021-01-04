class AddIsDeletedToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :is_deleted, :boolean, default: :false
  end
end
