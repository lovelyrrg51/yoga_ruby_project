class AddForeignKeysToUserRoles < ActiveRecord::Migration
  def up
    execute <<-SQL
        ALTER TABLE user_roles
        ADD CONSTRAINT fk_user_roles_users
        FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE;

        ALTER TABLE user_roles
        ADD CONSTRAINT fk_user_roles_user_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id) ON DELETE CASCADE;
    SQL
  end
  def down
  	execute <<-SQL
        ALTER TABLE user_roles
        DROP CONSTRAINT fk_user_roles_users;
        ALTER TABLE user_roles
        DROP CONSTRAINT fk_user_roles_user_roles;
    SQL
  end
end
