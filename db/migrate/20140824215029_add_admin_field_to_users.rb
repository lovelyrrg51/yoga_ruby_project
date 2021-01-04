class AddAdminFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :super_admin, :boolean, :default => false
    add_column :users, :digital_store_admin, :boolean, :default => false
  end
end
