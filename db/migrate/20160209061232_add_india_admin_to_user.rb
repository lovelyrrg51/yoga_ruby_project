class AddIndiaAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :india_admin, :boolean, default: false
  end
end
