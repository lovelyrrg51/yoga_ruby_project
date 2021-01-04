class CreateCreateForumRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :create_forum_requests do |t|
      t.string :name
      t.integer :no_of_people
      t.string :about_forum
      t.string :description
      t.string :motive
      t.integer :user_id

      t.timestamps
    end
  end
end
