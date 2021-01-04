class AddUsersRolesJoinTable < ActiveRecord::Migration
  def change
    create_table :user_roles, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end
    add_index :user_roles, [:role_id, :user_id], :unique => true
  end
end
