class AddColumnVirtualRoleToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :virtual_role, :integer
  end
end
