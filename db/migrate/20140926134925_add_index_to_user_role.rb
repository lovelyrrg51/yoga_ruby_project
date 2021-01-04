class AddIndexToUserRole < ActiveRecord::Migration
  def change
    add_index :user_roles, :user_id
    add_index :user_roles, :role_id
  end
end
