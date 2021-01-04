class AddEventAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :event_admin, :boolean, default: :false
  end
end
