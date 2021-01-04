class AddIdToUserRole < ActiveRecord::Migration[5.0]
  def up
    drop_table :user_roles, if_exists: true

    create_table :user_roles do |t|
      t.references :role, index: true
      t.references :user, index: true
      t.datetime :deleted_at
      t.integer :whodunnit
    end
    add_index :user_roles, [:role_id, :user_id], :unique => true
    add_index :user_roles, :deleted_at

  end

  def down
    drop_table :user_roles, if_exists: true
  end
end
