class AddColumnwhodunnitToShivyogChangeLog < ActiveRecord::Migration[5.0]
  def change
    add_column :shivyog_change_logs, :whodunnit, :integer
    add_index :shivyog_change_logs, :whodunnit
  end
end
