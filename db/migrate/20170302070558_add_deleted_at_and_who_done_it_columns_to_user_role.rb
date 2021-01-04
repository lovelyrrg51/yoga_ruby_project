class AddDeletedAtAndWhoDoneItColumnsToUserRole < ActiveRecord::Migration[5.0]
  def change
    add_column :user_roles, :deleted_at, :datetime
    add_index :user_roles, :deleted_at
    add_column :user_roles, :whodunnit, :integer
  end
end
