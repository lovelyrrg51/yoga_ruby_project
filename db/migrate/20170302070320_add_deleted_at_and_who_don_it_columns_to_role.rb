class AddDeletedAtAndWhoDonItColumnsToRole < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :deleted_at, :datetime
    add_index :roles, :deleted_at
    add_column :roles, :whodunnit, :integer
    add_column :roles, :role_type, :integer
  end
end
