class AddOldForumIdToSyClub < ActiveRecord::Migration
  def change
    add_column :sy_clubs, :old_forum_id, :integer
  end
end
