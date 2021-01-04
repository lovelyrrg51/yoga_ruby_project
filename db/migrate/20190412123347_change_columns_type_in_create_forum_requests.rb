class ChangeColumnsTypeInCreateForumRequests < ActiveRecord::Migration[5.2]
  def change
  	change_column :create_forum_requests, :no_of_people, :string
  	change_column :create_forum_requests, :about_forum, :text
  	change_column :create_forum_requests, :description, :text
  end
end
