class CreateSyClubUserRoles < ActiveRecord::Migration
  def change
    create_table :sy_club_user_roles do |t|
      t.string :role_name

      t.timestamps
    end
  end
end
