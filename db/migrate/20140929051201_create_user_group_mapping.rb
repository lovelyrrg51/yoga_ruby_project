class CreateUserGroupMapping < ActiveRecord::Migration
  def change
    create_table :user_group_mappings do |t|
      t.integer :user_id, :null => false, :references => [:users, :id]
      t.integer :user_group_id, :null => false, :references => [:user_groups, :id]
      
      t.timestamps
    end
    add_index :user_group_mappings, [:user_id, :user_group_id], :unique => true
  end
end
