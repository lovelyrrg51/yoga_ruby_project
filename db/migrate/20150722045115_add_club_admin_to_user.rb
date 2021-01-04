class AddClubAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :club_admin, :boolean, :default => :false
  end
end
