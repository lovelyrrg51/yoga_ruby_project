class AddAnnouncementTextToColleciton < ActiveRecord::Migration[5.1]
  def change
    add_column :collections, :announcement_text, :text
  end
end
