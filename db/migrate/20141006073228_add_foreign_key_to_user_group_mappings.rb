class AddForeignKeyToUserGroupMappings < ActiveRecord::Migration
  def up
    execute <<-SQL
        ALTER TABLE user_group_mappings
        ADD CONSTRAINT fk_ugm_users
        FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE;

        ALTER TABLE user_group_mappings
        ADD CONSTRAINT fk_ugm_user_groups
        FOREIGN KEY (user_group_id)
        REFERENCES user_groups(id) ON DELETE CASCADE;
    SQL
    add_index :user_group_mappings, :user_id
    add_index :user_group_mappings, :user_group_id
  end
  def down
  	execute <<-SQL
        ALTER TABLE user_group_mappings
        DROP CONSTRAINT fk_ugm_users;
        ALTER TABLE user_group_mappings
        DROP CONSTRAINT fk_ugm_user_groups;
    SQL
    remove_index :user_group_mappings, :user_id
    remove_index :user_group_mappings, :user_group_id
  end
end
