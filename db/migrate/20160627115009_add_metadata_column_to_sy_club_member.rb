class AddMetadataColumnToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :metadata, :text
  end
end
